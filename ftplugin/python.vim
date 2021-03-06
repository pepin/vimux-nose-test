if exists("g:loaded_vimux_nose_test") || &cp
  finish
endif
let g:loaded_vimux_nose_test = 1
map <silent> <LocalLeader>t :call VimuxRunCommand("run-tests.sh")<CR>
map <silent> <LocalLeader>f :RunAllNoseTests<CR>
map <silent> <Leader>t :call VimuxRunCommand("run-tests.sh")<CR>
map <silent> <Leader>f :RunAllNoseTests<CR>
map <silent> <LocalLeader>m :RunFocusedNoseTests<CR>

if !has("ruby")
  finish
end

command RunAllNoseTests :call s:RunAllNoseTests()
command RunFocusedNoseTests :call s:RunFocusedNoseTests()

function s:RunAllNoseTests()
  ruby NoseTest.new.run_all
endfunction

function s:RunFocusedNoseTests()
  ruby NoseTest.new.run_focused
endfunction

ruby << EOF
module VIM
  class Buffer
    def method_missing(method, *args, &block)
      VIM.command "#{method} #{self.name}"
    end
  end
end

class NoseTest
  def current_file
    VIM::Buffer.current.name
  end

  def line_number
    VIM::Buffer.current.line_number
  end

  def virtualenv
    if Vim.evaluate('exists("g:NoseVirtualenv")') != 0
      ". #{Vim.evaluate('g:NoseVirtualenv')} && "
    else
      ""
    end
  end

  def testruncmd
    if Vim.evaluate('exists("g:NoseTestRunCmd")') != 0
      "#{Vim.evaluate('g:NoseTestRunCmd')}"
    else
      "nosetests"
    end
  end

  def noselinecmd
    if Vim.evaluate('exists("g:NoseLineCmd")') != 0
      "#{Vim.evaluate('g:NoseLineCmd')}"
    else
      "noseline"
    end
  end

  def run_all
    send_to_vimux("#{virtualenv} #{testruncmd} '#{current_file}'")
  end

  def run_focused
    send_to_vimux("#{virtualenv} #{noselinecmd} '#{current_file}' --line #{line_number}")
  end

  def send_to_vimux(test_command)
    Vim.command("call RunVimTmuxCommand(\"#{test_command} $NOSE_OPTS\")")
  end
end
EOF
