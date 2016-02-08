# 0-to-code
## Getting from total zero to Visual Studio Code

If you follow any tutorials on modern web development, it's easy to get lost in an abundance of cryptic incantations involving "npm", "bower", "git" and "yo". It's especially challenging if you are using Windows and are used to the Visual Studio IDE tooling: it's *different*.

This set of scripts will help you to get all tools that you need to be productive with web development using the tools produced by NodeJS/npm, bower and yo communities, along with the newest kid on the block - Visual Studio Code.

### Principles of this toolset

1. One script to install all tooling that you need.
2. All tools will be installed for current user only, whenever possible.
3. Limited user accounts are supported and UAC elevations are done as part of the installation.
4. All necessary environment variable changes are made on the user account level.

### What is installed

1. Chocolatey - this is the magic that makes "one script" installation possible.
2. ConEmu - you should be ready to the fact that a lot of things will be done in the console, this is a great alternative to a good ole CMD.
3. NodeJS and NPM - the method of delivery for all these great tools which you'll be using later.
4. Default set of modules installed globally - bower, yo and its ASP.NET generator, typescript, tsd (access to DefinitelyTyped goodness), gulp and grunt.
5. GIT.
6. .NET vNext.
7. Visual Studio Code.

## How to install

Download this repository's contents as ZIP, unzip it and run this from the command line:

```
powershell -Command "& { dir *.ps*1 | Unblock-File }"
powershell -File .\install.ps1
```

First line will remove blocking from scripts downloaded from Internet. Second line will actually install the software.

If PowerShell complains on disabled scripts, run the command shown below and then repeat the previous command:

```
powershell -Command "& { Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned }"
```

You might be seeing a couple of UAC elevation prompts - this is expected: ConEmu and NodeJS are installed globally. At the same time, NPM (package manager for NodeJS) is configured to use paths that are local to the currently logged in user, so "npm install XXX -g" will install "global" module locally to your user account.

By default the installation will use your user profile folder as a "root". If you want to change this, please edit $global:root variable in settings.psm1 before running install.ps1. Be aware that .NET vNext will install into your user profile folder regardless.

After installation completed, please close the command prompt window and open another one, or better yet, start ConEmu. This is required, because changes in the environment variables will not be picked up otherwise. You should expect commands like "choco", "bower", "yo", "npm", "git" and "code" to be available in the new console session.

Start coding!
