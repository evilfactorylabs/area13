<img alt="evilfactorylabs/area13" src="https://i.imgur.com/Ae6dt8p.png" width="100%">

## Motivation

This project aims to minimize operation overhead by following GitOps practices as well as using Infrastructure as a Code approaches.

Currently this project covers:

- Managing DNS from DNS Registrars to DNS Servers
- Managing VPC thing like Cloud firewall

If you're curious about the infrastructure behind [evilfactorylabs.org](https://www.evilfactorylabs.org) websites as well as other projects behind it, this repository should explain it all.

## Prerequisites

You don't technically need to run or setup anything on your end. But if you want to setup for your own needs, you can take a look into [`shell.nix`](./shell.nix) and [`.envrc.example`](./.envrc.example) or you can just install [Terraform](https://terraform.io) on your machine (and messing with your own very [environment variables](https://direnv.net)).

You have to know a little knowledge in using Terraform so you know what you're doing ;)

## How to use

You can just clone this repo, create a new branch, and push your changes. Anyone with direct write access to the repository (i.e: making a pull request from this repo) will propagate `terraform plan` command behind the scenes. Only repository maintainers can initialize `terraform apply` but who knows, right?

## Maintainers

- [faultables](https://github.com/faultables), @evilfactorylabs

## License

[Unlicense](./LICENSE)
