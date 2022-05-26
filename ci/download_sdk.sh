if [ $OS_NAME = 'osx' ]; then
    if [[ ! -d $HOME/sdk/MacOSX10.9.sdk ]]; then
        git clone https://github.com/phracker/MacOSX-SDKs $HOME/sdk
    fi
fi
