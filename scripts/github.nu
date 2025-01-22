#!/usr/bin/env nu

def --env "main get github" [] {

    mut github_token = ""
    if "GITHUB_TOKEN" not-in $env {
        $github_token = (gh auth token | into string)
    } else {
        $github_token = $env.GITHUB_TOKEN
    }

    $"export GITHUB_TOKEN=($github_token)\n" | save --append .env

    {token: $github_token}
}