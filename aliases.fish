# vim: filetype=sh
# Tip from M Subelsky:
function ea; vim ~/.config/fish/aliases.fish; and . ~/.config/fish/aliases.fish; end
function ag; grep $argv[1] ~/.config/fish/aliases.fish; end

function up; cd ..; end
function bk; cd - ; end
function hm; cd ~ ; end

function bx; bundle exec; end
function rsh; pry --require rake; end

function gs; git status -s; end
function gd; git diff -b --color; end
function gl; git log; end
function gb; git branch; end
function gp; git pull; end
function GP; git push; end

function s;  grep $argv[1] -Rn . | less; end
function md;  mkdir $argv[1]; and cd $argv[1]; end

function blerg; echo blerg $argv[1] ferg snerg; end
