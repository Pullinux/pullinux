use libplx::util::{plx_share_path, plx_tmp_path};

use std::path::{PathBuf, Path};
use std::io::{ErrorKind};
use std::{
    fs::{File, OpenOptions},
    io::{self, BufRead, BufReader, Seek, SeekFrom, Write},
    process::{Command, ExitStatus, Stdio},
    thread::sleep,
    time::Duration,
};
use sysinfo::{System};


use std::fs;

pub fn plx_sources_path() -> PathBuf {
    plx_share_path().join("sources")
}

pub fn plx_package_source_path(source : &str) -> PathBuf {
    plx_sources_path().join(source)
}

pub fn first_subdir<P: AsRef<Path>>(root: P) -> io::Result<Option<PathBuf>> {
    let iter = match fs::read_dir(&root) {
        Ok(it) => it,
        Err(e) if e.kind() == ErrorKind::NotFound => return Ok(None),
        Err(e) => return Err(e),
    };

    for entry in iter {
        let entry = entry?;
        if entry.file_type()?.is_dir() {
            return Ok(Some(entry.path()));
        }
    }
    Ok(None)
}

const MAX_LOG_LINE: usize = 70;

fn clamp_chars(s: &str, max: usize) -> String {
    // simple, Unicode-scalar aware (good for ASCII logs)
    if s.chars().count() <= max {
        return s.to_string();
    }
    let mut out = String::new();
    for (i, ch) in s.chars().enumerate() {
        if i >= max.saturating_sub(1) { break; } // leave room for '…'
        out.push(ch);
    }
    out.push('…');
    out
}


fn bar(label: &str, pct: f32, width: usize) -> String {
    let pct = pct.clamp(0.0, 100.0);
    let filled = ((pct / 100.0) * width as f32).round() as usize;
    let filled = filled.min(width);
    let s = "█".repeat(filled) + &"░".repeat(width - filled); // fallback: "#" + " "
    format!("{label} [{s}] {:5.1}%", pct)
}

pub fn file_size<P: AsRef<Path>>(path: P) -> io::Result<u64> {
    Ok(fs::metadata(path)?.len())
}


/// Run `cmd`, showing two bars (CPU/MEM) and the last line of `log_path`
/// on three lines, updated once per second.
pub fn run_with_resource_meter_and_tail(
    cmd: &mut Command,
    log_path: &Path,
) -> io::Result<ExitStatus> {
    let mut child = cmd.spawn()?;

    // sysinfo warmup
    let mut sys = System::new();
    sys.refresh_cpu();
    sys.refresh_memory();
    sleep(Duration::from_millis(250));

    // Tail state
    let mut log_file: Option<File> = None;
    let mut pos: u64 = 0;
    let mut last_line = String::from("(waiting for log...)");

    // Hide cursor while updating
    print!("\x1B[?25l");
    io::stdout().flush().ok();

    let mut drawn = false;

    while child.try_wait()?.is_none() {
        // CPU/MEM
        sys.refresh_cpu();
        sys.refresh_memory();
        let cpu = sys.global_cpu_info().cpu_usage();
        let total = sys.total_memory().max(1);
        let used = sys.used_memory();
        let mem = (used as f32 / total as f32) * 100.0;

        // Try to open the log once it's available
        if log_file.is_none() {
            if let Ok(f) = OpenOptions::new().read(true).open(log_path) {
                log_file = Some(f);
                pos = 0; // read from start once to get the current last line
            }
        }

        // Read any new log content and update `last_line`
        if let Some(file) = log_file.as_mut() {
            // handle truncation/rotation
            let len = file.metadata()?.len();
            if pos > len {
                pos = 0; // file shrank; start over
            }
            file.seek(SeekFrom::Start(pos))?;
            let mut reader = BufReader::new(file);
            let mut line = String::new();
            let mut saw = false;
            while reader.read_line(&mut line)? != 0 {
                last_line = line.trim_end().to_string();
                line.clear();
                saw = true;
            }
            // update stream position to new end
            pos = reader.into_inner().stream_position()?;
            if !saw && last_line.is_empty() {
                last_line = "(log empty)".into();
            }
        }

        // Render three lines
        let cpu_line = bar("CPU", cpu, 28);
        let mem_line = bar("MEM", mem, 28);
        // strip CRs so CR-based progress messages don't mess up your line
        let last_clean = last_line.replace('\r', "");

        let log_size = file_size(log_path)?;

        let mut kb = (log_size as f64) / (1024.0);  // MB
        let mut prefix = format!("LOG ({kb:.1} KB): ");

        if kb > 1024.0 {
            kb = kb / 1024.0;
            prefix = format!("LOG ({kb:.1} MB): ");
        }

        let content = last_clean.replace('\r', "");            // sanitize CRs
        let avail = MAX_LOG_LINE.saturating_sub(prefix.len()); // space for content
        let clipped = clamp_chars(&content, avail);
        let log_line = format!("{prefix}{clipped}");

        //let log_line = format!("LOG {last_clean}");

        if !drawn {
            println!("{cpu_line}");
            println!("{mem_line}");
            println!("{log_line}");
            drawn = true;
        } else {
            // Move up 3 lines, then clear from cursor down, then repaint all three
            print!("\x1B[3F\x1B[J");
            println!("{cpu_line}");
            println!("{mem_line}");
            println!("{log_line}");
        }
        io::stdout().flush()?;

        sleep(Duration::from_secs(1));
    }

    // Move cursor below the meter and show it again
    if drawn {
        // move cursor up 3 lines to the start of the CPU line,
        // then clear from cursor to end of screen (nukes all 3 lines)
        print!("\x1B[3F\x1B[J");
    }
    // show cursor again
    print!("\x1B[?25h");
    io::stdout().flush().ok();

    child.wait()
}

pub fn run_build(script: &Path, run_path: &Path) -> io::Result<()> {

    let log_path = run_path.join("plx_build.log");
    let log = OpenOptions::new()
        .create(true)
        .write(true)
        .truncate(true)
        .open(&log_path)?;

    let log_err = log.try_clone()?;

    println!("Running build... see {}", log_path.display());

    let status = run_with_resource_meter_and_tail(Command::new("bash")
        .args(["-e", "-l", "-c"])
        .arg(format!("source /usr/share/plx/bin/env.sh && cd {} && bash -e {}", run_path.display(), script.display()))
        .env("PCKBASE", script.parent().unwrap())
        .env("PCKDIR", plx_tmp_path().join("inst"))
        .stdout(Stdio::from(log))      // redirect stdout to build.log
        .stderr(Stdio::from(log_err))  // redirect stderr to the same file
        , &log_path)?;

    if status.success() {
        Ok(())
    } else {
        Err(io::Error::new(io::ErrorKind::Other, format!("build failed: {status}, see build log: {}", log_path.display())))
    }
}
