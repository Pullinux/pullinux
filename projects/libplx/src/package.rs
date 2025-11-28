use serde::{Serialize, Deserialize};
use std::path::{PathBuf, Path};

use crate::{db::plx_package_mark_installed, util::{clear_dir, plx_bin_path, plx_tmp_path, run_script, untar_into}};

#[derive(Debug, Serialize, Deserialize)]
pub enum DepType {
    Runtime,
    Build
}

#[derive(Debug, Serialize, Deserialize)]
pub struct DependencyInfo {
    pub name : String,
    pub version : String,
    pub dep_type : DepType,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Package {
    pub name : String,
    pub version : String,
    pub source : String,
    pub extras : Vec<String>,
    pub dependencies : Vec<DependencyInfo>,
    pub id : i64
}

impl Package {
    pub fn new(name : impl Into<String>, version : impl Into<String>, source : impl Into<String>) -> Self {
        Self {
            name: name.into(),
            version : version.into(),
            source : source.into(),
            extras : vec![],
            dependencies : vec![],
            id : -1
        }
    }
}

pub fn package_print(package : Package) {
    if let Ok(yaml) = serde_yaml::to_string(&package) {
        println!("{yaml}");
    }
}

pub fn package_load(yaml: &str) -> Result<Package, serde_yaml::Error> {
    serde_yaml::from_str(yaml)
}

pub fn package_yaml(package: Package) -> Result<String, serde_yaml::Error> {
    serde_yaml::to_string(&package)
}

pub fn package_binary_path(pck : &Package) -> PathBuf {
    plx_bin_path().join(format!("{}-{}-plx-1.2.txz", pck.name, pck.version))
}


pub fn package_install(pck : &Package) -> anyhow::Result<()> {
    let bin_path = package_binary_path(&pck);
    
    if !bin_path.exists() {
        panic!("Can't find built package: {}", bin_path.display());
    }

    println!("Extracting install package...");

    let inst_path = Path::new("/").join(".install");
    let inst_script = inst_path.join("install.sh");

    if inst_path.exists() {
        //need to remove and clear out this folder first...
        println!("Removing old .install path...");
        std::fs::remove_dir_all(&inst_path)?;
    }

    untar_into(&bin_path, Path::new("/"))?;

    if inst_script.exists() {
        println!("Running installer...");

        run_script(&inst_script, &inst_path)?;

        std::fs::remove_dir_all(&inst_path)?;
    }

    plx_package_mark_installed(&pck.name)?;

    println!("Install Complete {}-{}", pck.name, pck.version);
    println!("");
    
    Ok(())
}
