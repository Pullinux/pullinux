
use libplx::{db::{plx_find_all_dependencies, plx_find_package, plx_package_installed}, package::{package_binary_path, package_install, package_load, package_print, package_yaml, DepType, DependencyInfo, Package}, util::plx_bin_path};
use std::env;

use crate::build::build_package;

pub mod build;
pub mod utils;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut package: Option<String> = None;
    let mut version: Option<String> = None;

    for arg in env::args().skip(1) { // skip program name
        if let Some(val) = arg.strip_prefix("--package=") {
            package = Some(val.to_string());
        } else if let Some(val) = arg.strip_prefix("--version=") {
            version = Some(val.to_string());
        }
    }

    let val = env::var("PLX_ROOT").unwrap_or(String::new());

    println!("ROOT: {}", val);

    if let Some(pck) = package {
        let pck_info = plx_find_package( &pck)?;

        println!("Got Package: {}", pck_info.version);
        
        let yaml = package_yaml(pck_info)?;

        println!("YAML:");
        println!("{yaml}");

        let deps = plx_find_all_dependencies(&pck)?;

        println!("Dependencies need built:");
        println!("{:?}", deps);
        println!("");

        for dep in deps {
            if plx_package_installed(&dep)? {
                println!("Package already installed: {}", dep);
                continue;
            }

            let pck = plx_find_package(&dep)?;
            let pck_bin = package_binary_path(&pck);

            if !pck_bin.exists() {
                build_package(&pck)?;
            } else {
                println!("Using pre-built package: {}", pck_bin.display());
            }
            
            package_install(&pck)?;
        }

        let pck_info = plx_find_package(&pck)?;
        let pck_bin = package_binary_path(&pck_info);

        if !pck_bin.exists() {
            build_package(&pck_info)?;
        } else {
            println!("Using pre-built package: {}", pck_bin.display());
        }
        
        package_install(&pck_info)?;
    }

    Ok(())
}
