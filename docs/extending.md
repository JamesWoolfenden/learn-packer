# Third Party Extensions

The comment provisioner is an example of a third party extension for Packer, and is a little bit of fun, so what's not to like! If you have the Golang Build environment already set-up that is.

Clone the repository and build the executable.

```go
git clone https://github.com/SwampDragons/packer-provisioner-comment
cd packer-provisioner-comment
go mod init main
go build
mkdir ~/.packer.d/plugins
mv main ~/.packer.d/plugins/packer-provisioner-comment
```

And move it to the plugin directory.

If you built on Windows, that last 2 lines should be:

```powershell
mkdir "$env:APPDATA/packer.d/plugins"
mv main.exe "$env:APPDATA/packer.d/plugins/packer-provisioner-comment.exe"
```

But moving the build executable plugin to my user profile worked for me:

```powershell
mkdir "$env:USERPROFILE/packer.d/plugins"
mv main.exe "$env:USERPROFILE/packer.d/plugins/packer-provisioner-comment.exe"
```

Taking my example from <https://github.com/SwampDragons/packer-provisioner-comment> as **bubble.json**

```json
{
  "builders": [
    {
      "type": "null",
      "communicator": "none"
    }
  ],
  "provisioners": [
    {
      "type": "comment",
      "comment": "Begin",
      "ui": true,
      "bubble_text": true
    },
    {
      "type": "shell-local",
      "inline": ["echo \"This is a shell script\""]
    },
    {
      "type": "comment",
      "comment": "In the middle of Provisioning run",
      "ui": true
    },
    {
      "type": "shell-local",
      "inline": ["echo \"This is another shell script\""]
    },
    {
      "type": "comment",
      "comment": "this comment is invisible and won't go to the UI"
    },
    {
      "type": "comment",
      "comment": "End",
      "ui": true,
      "bubble_text": true
    }
  ]
}
```

and running:

```bash
$packer build .\bubble.json
null output will be in this color.

==> null:   ____                   _
==> null:  | __ )    ___    __ _  (_)  _ __
==> null:  |  _ \   / _ \  / _` | | | | '_ \
==> null:  | |_) | |  __/ | (_| | | | | | | |
==> null:  |____/   \___|  \__, | |_| |_| |_|
==> null:                  |___/
==> null:
==> null: Running local shell script: C:\Users\jim_w\AppData\Local\Temp\packer-shell332136251.cmd
    null:
    null: C:\code\packer>echo "This is a shell script"
    null: "This is a shell script"
==> null: In the middle of Provisioning run
==> null: Running local shell script: C:\Users\jim_w\AppData\Local\Temp\packer-shell954744271.cmd
    null:
    null: C:\code\packer>echo "This is another shell script"
    null: "This is another shell script"
==> null:   _____               _
==> null:  | ____|  _ __     __| |
==> null:  |  _|   | '_ \   / _` |
==> null:  | |___  | | | | | (_| |
==> null:  |_____| |_| |_|  \__,_|
==> null:
Build 'null' finished.

==> Builds finished. The artifacts of successful builds are:
--> null: Did not export anything. This is the null builder
```

I can see me liking and using this one more.

!!!NOTE "Extending Packer"

    <https://www.packer.io/docs/extending/plugins.html>
