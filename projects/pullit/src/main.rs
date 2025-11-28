
use libplx::{db::init::{plx_add_deps, plx_db_init}, package::{package_load, package_print, package_yaml, DepType, DependencyInfo, Package}};

fn main() -> Result<(), Box<dyn std::error::Error>> {

    let mut add_deps = false;
    let mut package: Option<String> = None;

    for arg in std::env::args().skip(1) { // skip program name
        if arg == "adddeps" {
            add_deps = true;
            continue;
        }

        if add_deps {
            if package.is_none() {
                package = Some(arg.to_string());
            } else if let Some(pkg) = package.as_deref() {
                plx_add_deps(&pkg, &arg.to_string())?;
            }
        }
    }


    //plx_db_init()?;

    Ok(())
}
