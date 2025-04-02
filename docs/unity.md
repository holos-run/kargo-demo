# Unity

Unity testing uses `scripts/unity` as the entrypoint.

- Keep it a simple `go test ./...`
- Use `go.mod` replacements to pin versions of cue and holos.
- Testing against `cue` makes life much easier for the cue team.
- Do not use `holos` for unity test cases, it makes their life harder.
- Run holos with `--log-level=debug` to obtain equivalent `cue` commands.
