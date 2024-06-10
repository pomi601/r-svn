FROM mcr.microsoft.com/windows/servercore:ltsc2022 as base

ARG RTOOLS=rtools44-6104-6039.exe

# RUN powershell -Command Invoke-WebRequest \
#     -Uri "https://cran.r-project.org/bin/windows/Rtools/rtools44/files/$env:RTOOLS" \
#     -OutFile $env:RTOOLS

COPY $RTOOLS $RTOOLS

RUN powershell -Command \
    $ErrorActionPreference = 'Stop'; \
    Start-Process $env:RTOOLS -ArgumentList '/verysilent /suppressmsgboxes /norestart' -Wait ; \
    Remove-Item $env:RTOOLS -Force

RUN powershell -Command \
    $ErrorActionPreference = 'Stop'; \
    Invoke-WebRequest \
    -Uri "https://yihui.org/tinytex/install-bin-windows.bat" \
    -OutFile "install-bin-windows.bat" ; \
    Start-Process "install-bin-windows.bat" -Wait ; \
    Remove-Item "install-bin-windows.bat" -Force



RUN powershell -Command \
    Write-Output \
    'source /etc/profile', \
    'export PATH=/x86_64-w64-mingw32.static.posix/bin:$PATH', \
    'export PATH=/c/Users/ContainerAdministrator/AppData/Roaming/TinyTex/bin/windows:$PATH', \
    'export TAR=/usr/bin/tar',          \
    'export TAR_OPTIONS=--force-local', \
    'echo Hello, world!'               \
    > env.sh

COPY ./ src/

ENTRYPOINT ["c:\\rtools44\\usr\\bin\\env", "MSYSTEM=MSYS", \
    "MSYS=nonnativeinnerlinks" , \
    "/usr/bin/bash", "--init-file", "/c/env.sh", "-i"]

