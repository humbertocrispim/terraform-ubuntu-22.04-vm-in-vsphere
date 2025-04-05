# Code Citations

## License: MIT
https://github.com/GlupShitto/Terraform/tree/e9ee50294e24f456bb86b883679bb0b1ec761324/main.tf

```
${path.module}/templates/metadata.yaml", local.templatevars))
      "guestinfo.metadata.encoding" = "base64"
      "guestinfo.userdata"          = base64encode(templatefile("${path.module}/templates/userdata.yaml",
```


## License: MIT
https://github.com/daeric/terraform-nc-vmware-fortinet/tree/e122e2ebf597d9e2f21529b5c9d4f7fb96bc07a8/main.tf

```
.metadata"          = base64encode(templatefile("${path.module}/templates/metadata.yaml", local.templatevars))
      "guestinfo.metadata.encoding" = "base64"
      "guestinfo.userdata"          = base64encode(templatefile("${path.module
```

