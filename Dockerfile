FROM mcr.microsoft.com/windows/servercore:ltsc2022 as base

ARG MSYS=https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe
ARG TINYTEX=https://yihui.org/tinytex/install-bin-windows.bat
ARG INNOSETUP=https://jrsoftware.org/download.php/is.exe
ARG RTOOLS=https://github.com/r-windows/rtools-chocolatey/releases/download/6104/rtools44-toolchain-libs-base-6104.tar.zst

# SHELL ["cmd", "/S", "/C"]
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# InnoSetup
RUN \
    Start-Process tzutil -ArgumentList '/s "GMT Standard Time"' -Wait; \
    Invoke-WebRequest \
    -Uri "${env:INNOSETUP}" \
    -OutFile is.exe ; \
    Start-Process is.exe -ArgumentList "/verysilent" -Wait ; \
    Remove-Item is.exe

# https://www.msys2.org/docs/ci/
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Start-Process tzutil -ArgumentList '/s "GMT Standard Time"' -Wait; \
    Invoke-WebRequest \
    -UseBasicParsing \
    -Uri "${env:MSYS}" \
    -OutFile msys2.exe ; \
    .\msys2.exe -y -oC:\; \
    Remove-Item msys2.exe ; \
    function msys() { C:\msys64\usr\bin\bash.exe @('-lc') + @Args; } \
    msys ' ';

# TinyTex, from https://github.com/r-lib/actions/blob/v2-branch/setup-tinytex/src/setup-tinytex.ts
RUN \
    Start-Process tzutil -ArgumentList '/s "GMT Standard Time"' -Wait; \
    Invoke-WebRequest \
    -Uri "${env:TINYTEX}" \
    -OutFile "install-bin-windows.bat" ; \
    Start-Process "install-bin-windows.bat" -Wait ; \
    Remove-Item "install-bin-windows.bat" -Force;

# From build-svn.yaml
RUN \
    Start-Process "$env:AppData/TinyTeX/bin/windows/tlmgr" -ArgumentList 'update --self' -Wait; \
    Start-Process "$env:AppData/TinyTeX/bin/windows/tlmgr" -ArgumentList 'install texinfo' -Wait; \
    Start-Process "$env:AppData/TinyTeX/bin/windows/tlmgr" -ArgumentList 'list --only-installed' -Wait;

# From build-svn.yaml
RUN \
    function msys() { C:\msys64\usr\bin\bash.exe @('-lc') + @Args; } \
    msys 'pacman --noconfirm -S git make perl curl texinfo texinfo-tex rsync zip unzip diffutils wget subversion'; \
    msys 'pacman --noconfirm -Scc';

# From build-svn.yaml
RUN \
    function msys() { C:\msys64\usr\bin\bash.exe @('-lc') + @Args; } \
    $command = 'curl -sSL ' + ${env:RTOOLS} + ' | tar x --zstd -C /c/'; \
    echo $command; \
    msys $command;

# Some missing packages during vignette builds
RUN \
    Start-Process "$env:AppData/TinyTeX/bin/windows/tlmgr" \
    -ArgumentList 'install grfext inconsolata makeindex listings parskip' -Wait;

COPY ./ src/

# From build-svn.yaml, except use mini file
RUN \
    function msys() { C:\msys64\usr\bin\bash.exe @('-lc') + @Args; } \
    msys "sed -i.bak 's/rsync -rc/rsync -r/' tools/rsync-recommended"; \
    msys 'cd /c/src && .github/scripts/win-installer.sh'


ENTRYPOINT ["C:\\msys64\\usr\\bin\\bash.exe", "-li"]

# # RUN powershell -Command Invoke-WebRequest \
# #     -Uri "https://cran.r-project.org/bin/windows/Rtools/rtools44/files/$env:RTOOLS" \
# #     -OutFile $env:RTOOLS

# COPY $RTOOLS $RTOOLS

# RUN powershell -Command \
#     $ErrorActionPreference = 'Stop'; \
#     Start-Process $env:RTOOLS -ArgumentList '/verysilent /suppressmsgboxes /norestart' -Wait ; \
#     Remove-Item $env:RTOOLS -Force





# COPY ./ src/

# ENTRYPOINT ["c:\\rtools44\\usr\\bin\\env", "MSYSTEM=MSYS", \
#     "MSYS=nonnativeinnerlinks" , \
#     "/usr/bin/bash", "--init-file", "/c/env.sh", "-i"]
