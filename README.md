# About this project
[![ShellCheck](https://img.shields.io/badge/code%20style-shellcheck-green)](https://www.shellcheck.net/) [![Dependencies](https://img.shields.io/badge/dependencies-none-brightgreen)](#) [![License](https://img.shields.io/github/license/lukekoch/conplex)](https://github.com/lukekoch/conplex/blob/main/LICENSE) [![Man Pages](https://img.shields.io/badge/docs-man%20pages-blueviolet)](#)
 [![Repository Size](https://img.shields.io/github/repo-size/lukekoch/conplex.svg)](https://github.com/lukekoch/conplex) 

conda environments are a great choice for managing software installations for a large group of users especially in the computer science spaces. However, if users install the same software in their own conda installation (thus their own home directories), the resulting redundancy can seriously impact the performance of NFS or similar network storage solutions. Shared conda environments are the obvious solution. conplex offers functionalities to ease the usage and setup of these environments especially for beginner-level end users. Installing conplex requires no special privileges or dependencies and takes less than 10 minutes. conplex is not intended to replace higher-level module-style management solutions like [environment modules](https://modules.readthedocs.io/en/latest/index.html#).

# Available commands
## Common
- ``conplex list`` : Lists all environments registered for usage with conplex.
- ``conplex load <env-name>`` : Load an environment identified by the `<env-name>` obtained using the `conplex list` command. The behaviour is equivalent to `conda load <env>`, with the exception for some additional information being displayed in the CLI.
- ``conplex unload`` : Deactivate the currently loaded environments. This command is equivalent to `conda deactivate` and mainly for the sake of completeness.
- ``conplex help`` : Prints a helpful messahe

# Setup
## Prequisites
Before the setting up complex, perform the following steps:
1. Designate one directory to host the shared environments 
2. Export the path to the `CONPLEX_DIRECTORY` variable
3. Create a `envs.tsv` file
4. Export the path to the TSV file to the `CONPLEX_ENVS_FILE` variable

In total you need 4 commands
```bash
touch /path/to/env-dir/envs.tsv
echo 'CONPLEX_ENVS_FILE=/path/to/env-dir/envs.tsv' >> ~/.bashrc
```

## Creating a test environment
You can create a shared environment using 
```bash
conda create -p /path/to/env-dir/test
```

## Registering the test environments
Open the ``/path/to/env-dir/envs.tsv`` using your preferred editor. Each environment is defined in one row in the env file. For now you can test using:
```
test	v1.0	stable	test_command	This is a test environment	/path/to/env-dir/test

```
Read the [section on the environments file](#the-environments-config-file) for more information.

## Making conplex executable
Copy the conplex script to your bin folder to make it available as a command
```bash
cp conplex.sh ~/bin/conplex.sh
chmod +x ~/bin/conplex
echo 'alias conplex="source ~/bin/conplex.sh"' >> ~/.bashrc
```
Source your .bashrc `source ~/.bashrc`, then check that conplex is available using `conplex`. You can now list all available environments using ``conplex list``.

Note: The alias in combination with `source` is required in order for conplex to load the conda environment in the parent shell.


# Remarks on user permissions
It's generally recommended to limit which users can modify shared environments since one accidental change by an unexperienced user can break the evironment for everyone else. The user creating the conda environment automatically has write permissions for its directory, for all others the write access should be limited. E.g. using `chmod 755 /path/to/env-dir/test`. It is also possible to create a user group which has exclusive write permission to the overall ``$CONPLEX_DIRECTORY``.

# The environments config file
The config file is a simple, tab-separated text file with a total of 6 columns:

1. **The environment name:** This should typically be the name of the software in the environment or the project it belongs to. Keep this name short and concise since users have to type it in order to load the environment. Duplicate names are allowed as long as they provide differen version values in the second field. If no version is provided, conplex will default to the first entry in the TSV.
2. **The version:** The version of the software in the environment or the environment overall. If the user supplies a version in `conplex load`, conplex will filter by name and version.
3. **Status:** This should indicate to users in one word if the software is 'stable', 'dev', 'beta' etc.
4. **Stable commands:** How users can invoke the software installed in the environment.
5. **Notes:** This text will be displayed once a user load the environment
6. **Path:** The **global** path to the environment in question.

Each environment has exactly one entry in the config file. The fields 1,2 and 6 are required fields, all others can be filled with a single "-" if no further info is available. Always ensure that the number of tabs is consistent. The file should contain one empty last row.