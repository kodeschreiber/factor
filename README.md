# FACTOR
---
Factor is a build assistant tool designed to make organizing submodules and their construction much easier. It is installed as a GIT plugin.

When running the `git factor` command, you must be in the target directory containing this file or set the `FACTOR_FILE` environment variable to the path of the `factor.conf` file.

---

## Command Usage:
git factor OPERATION TARGET1 ... TARGETn  

OPERATIONS:
  - build:
      Firstly ensures that the '.factor' directory exists. Then, ensures the
      basic directory structure for the module is present. Git submodule is 
      then used to add/update the module. Then, check if the build needs to 
      continue; if the tag or buildscript change, or if the 'cache' directory 
      for the module is missing, then proceed, otherwise, exit 11. Attempt to 
      build each prerequiste. If successful, create cache directory and clean 
      the git module directory. If isolation is not set, set the environment
      variables and run the buildscript. Otherwise, create a bind-mount for
      the root and module directories in the cache, chroot into the cache,
      and execute the buildscript. Absolute paths defined in the PATH and
      LD_LIBRARY_PATH are converted for the chroot environment. Finally, 
      copy the contents of the cache into the 'prefix' directory.
    
  - clean:
      Remove the modules '.factor' directory
---

## Installation
Here's a simple layout diagram:  

![factor_diagram](factor.png)

Factor only requires a few things:
1. One or more '<filename>.ftr' files in the git repository
2. Commands: rsync, git

Simply run `make install` to install the binary. To set a custom path, do `make PREFIX='<path>' install`

---

## FTR files
FTR files can be located anywhere in your git repository. FTR files are essentially
`ini` files. In fact, they are desinged the same way that GIT configs are.
  
There are three types of sections you may use:
  - entry
  - exec
  - env
  
Meta sections are structured as:
```
[entry "name"]
  url=
  tag=
  requires=req1 ... reqN
  env=env1 ... envN
  prefix=
  exec=exec1 ... execN
```
Here are the rules to the CONF file:
1. `url` should specify the location to the target GIT repository. It is required.
2. `tag` must be a valid tag in that repository. The default is `master`
3. `requires` is a space-separated list of other resource names. They will be built first.
4. `env` is a space-separated list of section names in the `factor.conf`. Add entries to those sections; this will automatically export shell variables for your build scripts (no need to put 'export')
5. `prefix` is the final destination of your resource's build. It will given as the variable `PREFIX` in your build script. This value changes if `isolate` is defined. You may also use the `%git%` variable to specify the path your GIT project root.
6. `script` is the location of the buildscript to execute in the module's directory. The scipt must be set as execuatble. You may use the `%git%` syntax to specifiy the location.

Exec sections are free-form. They should be treated as parts to a script, later combined by
reference in the `entry` section.
  
Env sections are structured as:
```
[environment_name]
PATH=/bin:/usr/bin
CUSTOM_VAR=foo
CC=/usr/bin/gcc
```

Note that you do not need to put the `export` keyword. This is done automatically.

There is one reserved section called `factor` used to define global properties for
your repository. It is not required, but can be used to override default values as
outlined below:
```
[factor]

```
---

## Build Variables
The following variables are injected to every buildscript's environment:

- PREFIX_CACHE - Path to the `<gitfolder>/.factor/<module>/cache` directory.
- PREFIX_BUILD - Path defined by the `prefix` variable in the factor.conf
- GIT_ROOT - Path to the parent git directories root.
