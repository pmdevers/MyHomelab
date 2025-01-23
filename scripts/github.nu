#!/usr/bin/env nu

def --env "main get github" [] {

    mut github_token = ""
    if "GITHUB_TOKEN" not-in $env {
        $github_token = (gh auth token | into string)
    } else {
        $github_token = $env.GITHUB_TOKEN
    }

    if ($github_token == "") {
        print "please run 'gh auth login' to authenticate with GitHub"
        exit
    }

    $"export GITHUB_TOKEN=($github_token)\n" | save --append .env

    $github_token
}