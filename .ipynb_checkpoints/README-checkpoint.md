# FACTOR
---
Factor is a build assistant tool designed to make organizing submodules and their construction much easier. It is installed as a GIT plugin.

Here's a simple layout diagram:  

![factor_diagram](factor.png)

Factor only requires one thing:
1. The place that you wish to setup your .factor folder must containe a `factor.conf` file.

When running the `factor` command, you must be in the target directory containing this file or set the `FACTOR_FILE` environment variable to the path of the `factor.conf` file.

---

## The `factor.conf` file
The conf file is structured as:
```
[resource]
  url=
  tag=
  requires=req1 ... reqN
  env=env1 ... envN
  prefix=
  script=
```
Here are the rules to the CONF file:
1. `url` should specify the location to the target GIT repository. It is required.
2. `tag` must be a valid tag in that repository. The default is `master`
3. `requires` is a space-separated list of other resource names. They will be built first.
4. `env` is a space-separated list of section names in the `factor.conf`. Add entries to those sections; this will automatically export shell variables for your build scripts (no need to put 'export')
5. `prefix` is the final destination of your resource's build. It will given as the variable `PREFIX` in your build script. This value changes if `isolate` is defined. You may also use the `%git%` variable to specify the path your GIT project root.
6. `script` is the location of the buildscript to execute in the module's directory. The scipt must be set as execuatble. You may use the `%git%` syntax to specifiy the location.

## Command Usage:
git factor OPERATION TARGET1 ... TARGETn  

OPERATIONS:
  - sync:
      Firstly ensures that the '.factor' directory exists. Then, ensures the
      basic directory structure for the module is present. Git submodule is 
      then used to add/update the module.
      
  - build:
      Run 'sync' on the module. Then, check if the build needs to continue;
      if the tag or buildscript change, or if the 'cache' directory for the
      module is missing, then proceed, otherwise, exit 11. Attempt to build
      each prerequiste. If successful, create cache directory and clean the
      git module directory. If isolation is not set, set the environment
      variables and run the buildscript. Otherwise, create a bind-mount for
      the root and module directories in the cache, chroot into the cache,
      and execute the buildscript. Absolute paths defined in the PATH and
      LD_LIBRARY_PATH are converted for the chroot environment.
      
  - compose:
      Run 'build' on the module. Then copy the contents of the cache into
      the 'prefix' directory.
    
  - clean:
      Remove the modules '.factor' directory
   
  - prune:
      Remove the submodule. Then, run 'clean' on it. Then remove the entry
      from the 'factor.conf' file.

## Installation
Simply run `make install` to install the binary. To set a custom path, do `make PREFIX='<path>' install`

### A note on `isolate`
`isolate` is an experimental command used for special circumstances where a
build may require absolute/system-root paths to install correctly. Here are
the options:

```
isolate delta_dir [OPTIONS] CMD ARG1 ... ARGN

OPTIONS:
  -b|--bind <abs_dir>   Using an absolute path, bind this directory to the
                        new pseudo-root. NOTE: You cannot specify the delta
                        directory, not any of its parent folders
                        
  -l|--lower <abs_dir>  Using an absolute path, add a directory to the lowers
                        that are mounted during the overlay. NOTE: You cannot 
                        specify the delta directory, not any of its parent 
                        folders

  - delta_dir: The directory to deposite any changes made while in isolation
  - CMD ARGS: The command and arguments to be executed in the environment
  
EXAMPLES:
  ./isolate test -b /bin -b /usr/bin -b /lib -b /usr/lib echo hello
```

The script must be run as root. USE AT YOUR OWN RISK.
If you'd like a potentially safe way to test this, run it
in a Docker container.