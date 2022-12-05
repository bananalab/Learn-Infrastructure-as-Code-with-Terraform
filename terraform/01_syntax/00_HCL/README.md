# HCL

HCL is a toolkit for creating structured configuration languages that are both
human- and machine-friendly, for use with command-line tools. Although intended
to be generally useful, it is primarily targeted towards devops tools, servers,
etc.


## Why not YAML or JSON?
<details>
    <summary>JSON</summary>

```json
{
    "io_mode": "async",
    "service": {
        "http": {
            "web_proxy": {
                "listen_addr": "127.0.0.1:8080",
                "process": {
                    "main": {
                        "command": [
                            "/usr/local/bin/awesome-app",
                            "server"
                        ]
                    },
                    "mgmt": {
                        "command": [
                            "/usr/local/bin/awesome-app",
                            "mgmt"
                        ]
                    }
                }
            }
        }
    }
}
```

* High verbosity.
* Prone to brace matching errors.
* Serialization format.

</details>

<details>
    <summary>YAML</summary>

```yaml
---
io_mode: async
service:
  http:
    web_proxy:
      listen_addr: 127.0.0.1:8080
      process:
        main:
          command:
          - "/usr/local/bin/awesome-app"
          - server
        mgmt:
          command:
          - "/usr/local/bin/awesome-app"
          - mgmt
```

* Medium verbosity.
* Prone to whitespace errors.
* Serialization format.

</details>

<details>
    <summary>HCL</summary>

```hcl
io_mode = "async"

service "http" "web_proxy" {
  listen_addr = "127.0.0.1:8080"
  
  process "main" {
    command = ["/usr/local/bin/awesome-app", "server"]
  }

  process "mgmt" {
    command = ["/usr/local/bin/awesome-app", "mgmt"]
  }
}
```

* Medium verbosity
* Balances machine and human readability.
* Also has a JSON syntax.

</details>