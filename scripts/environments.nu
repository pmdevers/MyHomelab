#!/usr/bin/env nu

def --env "main get environment" [] {

    let environment = ls -s ./clusters/ 
        | select name 
        | input list -d name $"(ansi green_bold)Which environment do you want to use?(ansi yellow_bold)"
    
    print $"(ansi reset)"

    $"export ENVIRONMENT=($environment)\n" | save --append .env

    $environment.name
}