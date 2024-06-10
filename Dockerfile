FROM mcr.microsoft.com/windows/servercore:ltsc2022 as base

ARG MSYS=https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe
ARG TINYTEX=https://yihui.org/tinytex/install-bin-windows.bat
ARG INNOSETUP=https://jrsoftware.org/download.php/is.exe

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

# TinyTex
RUN \
    Start-Process tzutil -ArgumentList '/s "GMT Standard Time"' -Wait; \
    Invoke-WebRequest \
    -Uri "${env:TINYTEX}" \
    -OutFile "install-bin-windows.bat" ; \
    Start-Process "install-bin-windows.bat" -Wait ; \
    Remove-Item "install-bin-windows.bat" -Force;

COPY docker-setup.sh .
RUN \
    function msys() { C:\msys64\usr\bin\bash.exe @('-lc') + @Args; } \
    msys '/bin/sh /c/docker-setup.sh'; \
    Remove-Item docker-setup.sh

COPY ./ src/

# # RUN \
# #     tzutil /s "GMT Standard Time" \
# #     function msys() { C:\msys64\usr\bin\bash.exe @('-lc') + @Args; } \
# #     msys 'cd /c/src && .github/scripts/win-installer.sh'


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
