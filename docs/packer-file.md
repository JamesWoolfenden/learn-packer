# File Header

Files. Well apart from debugging this one's lost on me.

So for completeness here's as example using the file builder in the file **packer-file.json**:

```json
{
  "builders": [
    {
      "type": "file",
      "content": "# File Header \n multi-line also \n The End",
      "target": "output.md"
    }
  ]
}
```

Can't say I learned.

```bash
packer build .\packer-file.json

file output will be in this color.

Build 'file' finished.

==> Builds finished. The artifacts of successful builds are:
--> file: Stored file: output.md
```

Not much more to see.
