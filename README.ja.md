h2. これは何？

FirefoxのXULアプリケーションの内側でRubyインタープリタを動かすプログラム
です。
HTMLもどき（XUL）のGUIを使えるRubyと考えれば良いです。デスクトップアプリ
ケーションとなります。

h2. 環境
OSXで試しました。多分Linuxでも動くと思います。Windowsの場合はちょって手
を入れる必要があります。
Firefoxは31.0を、Rubyは2.1.2p95をそれぞれ使って動かしましたが、おそらく3
年前あたりのFirefoxでも動作するような気がします。Rubyは2.0以降なら問題な
く動きそうです。ただしFiddleが必須です。
また、組み込みRubyとして動作するので、Rubyは--enabled-sharedを有効にして
構築したバージョンの必要があります。

h2. 起動方法

ルートディレクトリのfireruby（シェルスクリプト）で起動します。

h3. 前提条件

FirefoxはLinuxなら/opt/firefox、OSXなら/Applications/Firefox.appにイン
ストールされていることを前提としています。

h3. 起動状態の確認方法

想定通りに起動できるとFirefoxの小さなウィンドウが開きます。下の方にRuby
のバージョン文字列が表示されていれば成功です。
ウィンドウにはテキストボックスがあるのでそこにスクリプトを入力してevalボ
タンをクリックすると、下の方に結果の文字列を表示します。
たとえば、3+5と入力すると8が表示されます。

h2. DOMの操作

DOMというクラスが定義されているのでそれを使ってDOMを操作します。
windowとdocumentはその名前を、それ以外のDOM要素はidを指定してDOMクラスの
インスタンスを作成してください。

h3. 例

{code:ruby}
win = DOM.new('window')
win.alert('hello')  # helloがアラート表示される
win.setTimeout("alert('hello');", 3000) # 3秒後にhelloがアラート表示され
る
{code}

h2. ソフトウェア構造

XULアプリケーションです（ただしXULRunnerを使うと余分なインストールが必要
になるので、Firefoxを使うようにしています）。

chrome/content の下にプログラムがあります。
* main.xul
** ウィンドウの定義
* main.js
** 起動時とDOMのイベントを処理するJavaScript。js-ctypes（内部はlibffi）を使ってRubyと会話します。
* main.rb 
** main.jsから呼ばれるRubyのスタブです。上記のDOMクラスが定義されています。fiddleを使ってJavaScriptのコールバック関数を呼び出してDOMを操作します。
