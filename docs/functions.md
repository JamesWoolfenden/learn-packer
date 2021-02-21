# functions

## template_dir

This is a built in Packer function, and it returns the path to the current file.

If you have to reference another file in a provisioner or as in the line below to AWS user data script file:

```json
"user_data_file": "{{template_dir}}/bootstrap_win.txt"
```

## timestamp

Always useful, to make name and strings unique.

```json
"{{timestamp}}"
```
