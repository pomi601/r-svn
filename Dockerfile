FROM mcr.microsoft.com/windows/servercore:ltsc2022 as base

# SHELL ["cmd", "/S", "/C"]
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Start-Process tzutil -ArgumentList '/s "GMT Standard Time"' -Wait; \
    Invoke-WebRequest \
    -UseBasicParsing \
    -Uri "https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe" \
    -OutFile msys2.exe ; \
    .\msys2.exe -y -oC:\; \
    Remove-Item msys2.exe ; \
    function msys() { C:\msys64\usr\bin\bash.exe @('-lc') + @Args; } \
    msys ' '; \
    # msys 'pacman --noconfirm -Syuu'; \
    # msys 'pacman --noconfirm -Syuu'; \
    msys 'pacman --noconfirm -S git make perl curl texinfo texinfo-tex rsync zip unzip diffutils'; \
    msys 'pacman --noconfirm -Scc';


RUN \
    function msys() { C:\msys64\usr\bin\bash.exe @('-lc') + @Args; } \
    msys 'curl -sSL "https://github.com/r-windows/rtools-chocolatey/releases/download/6104/rtools44-toolchain-libs-base-6104.tar.zst" | tar x --zstd -C /c/'

RUN \
    Invoke-WebRequest \
    -Uri "https://yihui.org/tinytex/install-bin-windows.bat" \
    -OutFile "install-bin-windows.bat" ; \
    Start-Process "install-bin-windows.bat" -Wait ; \
    Remove-Item "install-bin-windows.bat" -Force

RUN \
    tlmgr update --self; \
    tlmgr install texinfo; \
    tlmgr list --only-installed;

COPY ./ src/

RUN \
    function msys() { C:\msys64\usr\bin\bash.exe @('-lc') + @Args; } \
    msys 'cd /c/src && .github/scripts/win-check.sh'


# RUN powershell -Command Write-Output \
#     'source /etc/profile', \
#     'export PATH=/c/x86_64-w64-mingw32.static.posix/bin:$PATH', \
#     'export PATH=/c/Users/ContainerAdministrator/AppData/Roaming/TinyTex/bin/windows:$PATH', \
#     'export TAR=/usr/bin/tar',          \
#     'export TAR_OPTIONS=--force-local', \
#     'echo Hello, world!'                \
#     > env.sh

ENTRYPOINT ["C:\\msys64\\usr\\bin\\bash.exe", "--init-file", "/c/env.sh", "-li"]

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
