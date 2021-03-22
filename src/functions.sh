# Yes/Noプロンプトを出す関数
# 返り値: Yes=0, No=1
function prompt() {
  while true; do
    read -p "$1 (y/n): " yn
    case $yn in
        [Yy]* ) return 0;;
        [Nn]* ) return 1;;
        * ) echo "Please answer yes or no.";;
    esac
done
}