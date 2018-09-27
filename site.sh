if [[ -v TEDZSH_ENABLE_ITERM2_INTEGRATION ]]; then
    test -e "${HOME}/.oh-my-zsh/iterm2_shell_integration.zsh" && source "${HOME}/.oh-my-zsh/iterm2_shell_integration.zsh"
fi
if [[ -v TEDZSH_ENABLE_PYENV ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    alias pyenv='CFLAGS="-I$(brew --prefix openssl)/include" LDFLAGS="-L$(brew --prefix openssl)/lib" pyenv'
fi

if [[ -v TEDZSH_ENABLE_GOPATH ]]; then
    export PATH=$PATH:$HOME/go/bin
fi


if [[ -v TEDZSH_ENABLE_PRD_FUNC ]]; then
    function update_prd() {
        set -x
        rsync -a ~/.oh-my-zsh/ rdi-sysmgt1-2-prd.eng.sfdc.net:.oh-my-zsh/
        rsync -a ~/.zshrc rdi-sysmgt1-2-prd.eng.sfdc.net:.
        ssh -t rdi-sysmgt1-2-prd.eng.sfdc.net "( klist -s || kinit )"
        set +x
    }
    function prd() {
        ssh -t rdi-sysmgt1-2-prd.eng.sfdc.net "( klist -s || kinit )"
        ssh -t rdi-sysmgt1-2-prd.eng.sfdc.net "rsync -a --delete .oh-my-zsh/ $1:.oh-my-zsh/ ; rsync -a .zshrc $1:. "
        ssh -tt rdi-sysmgt1-2-prd.eng.sfdc.net ssh -t $1 zsh -l
    }
fi
if [[ -v TEDZSH_ENABLE_OPENSTACK ]]; then
    L_OS () 
    { 
        eval $(sudo cat /root/v3-openrc | grep ^export)
    }
fi
function deleet {
    emptydir="/tmp/$(uuidgen)"
    mkdir -p $emptydir
    rsync -a --delete --progress --stats $emptydir/ $1
    rm -rf $emptydir
}

if [[ -v TEDZSH_ENABLE_CUSTOM_GIT ]]; then
    # SENILE COMMIT BLOCKER
    GIT=$(whereis git)
    function commit() {
        grep -qHnr SENILE $($GIT rev-parse --show-toplevel) 2>/dev/null
        if [[ $? == 0 ]]
        then 
            echo "SENILE COMMIT"
        else 
            $GIT commit -v "$@"
        fi
    }
    function git() {
        if [[ $1 == "commit" ]]; then
            shift
            commit "$@"
        else
            $GIT "$@"
        fi
    }
fi

if [[ -v TEDZSH_ENABLE_CHECK_CODE_FUNC ]]; then
    function check_code() {
        CHECK_CODE_DIR=$HOME/.tmp/check_code
        mkdir -p $CHECK_CODE_DIR
        pycodestyle $* 2>&1 >| $CHECK_CODE_DIR/pycodestyle
        if [[ $? -ne 0 ]]; then
            echo "Coding style issues were found"
            cat $CHECK_CODE_DIR/pycodestyle
        else 
            echo "No coding style issues were found"
        fi
        pydocstyle $* 2>&1 >| $CHECK_CODE_DIR/pydocstyle
        if [[ $? -ne 0 ]]; then
            echo "Docstring style issues were found"
            cat $CHECK_CODE_DIR/pydocstyle
        else
            echo "No docstring style issues were found"
        fi
        pylint $* 2>&1 >| $CHECK_CODE_DIR/pylint
        if [[ $? -ne 0 ]]; then
            echo "Linting issues were found"
            cat $CHECK_CODE_DIR/pylint
        else
            echo "No linting issues were found"
        fi
    }
fi

if [[ -v TEDZSH_ENABLE_CUSTOM_BIN ]]; then
    export PATH=${PATH}:${HOME}/.local/bin:${HOME}/bin
fi

if [[ -v TEDZSH_ENABLE_ZSHENV ]]; then
    source .zshenv
fi
