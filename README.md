# AL2023 Setup Script

Amazon Linux 2023 bastion host boostrap script.

## Usage

전체 모듈 설치

```bash
curl -fsSL https://raw.githubusercontent.com/zenru1023/al2023-setup/main/setup.sh | bash
```

특정 모듈만 설치

```bash
curl -fsSL https://raw.githubusercontent.com/zenru1023/al2023-setup/main/setup.sh | bash -s -- --only kubectl,helm
```

특정 모듈을 제외하고 설치

```bash
curl -fsSL https://raw.githubusercontent.com/zenru1023/al2023-setup/main/setup.sh | bash -s -- --exclude docker,k9s
```

## Module List

| Name      |
| --------- |
| docker    |
| kubectl   |
| helm      |
| eksctl    |
| k9s       |
| yq        |
| jq        |
| terraform |

## License

This project is licensed under [BSD-3-Clause](LICENSE).
