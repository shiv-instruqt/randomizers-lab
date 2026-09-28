# Operation Randomize: Hands-on with Labs 2.0 Randomizers

An Instruqt **Labs 2.0** lab that covers all five randomizer resources, using a small but realistic scenario:

| Randomizer | Drives |
|---|---|
| `random_creature` | The vault's hostname (network alias), your shell prompt |
| `random_number` | The vault's listening port, the capstone's shard count |
| `random_password` | The vault password (`min_*` + `override_special`) and a digits-only PIN |
| `random_uuid` | The session primary key, plus a `substr()` short ID |
| `random_id` | A tenant namespace, in `hex`, `dec` and `base64` |

**Duration:** about 45 minutes · **Time limit:** 1h (+30m extension) · **Level:** beginner to intermediate

---

## Import into Instruqt

1. Push this folder to GitHub, either as its own repo or as a subfolder of an existing one:

   ```bash
   cd randomizers-lab
   git init && git branch -m main
   git add . && git commit -m "Operation Randomize: Labs 2.0 randomizers lab"
   git remote add origin git@github.com:<you>/randomizers-lab.git
   git push -u origin main
   ```

2. In Instruqt, open **Labs**, then **Import lab** (top right).
3. Pick your **Git account** and the repository.
4. Leave **Branch** on `main`. If the lab sits in a subfolder of a bigger repo, set **Root directory** to that folder (for example `randomizers-lab`).
5. Click **Import lab**. Wait for the sync status to show **Success**, then click **Play**.

After that, every `git push` syncs automatically.

> Optional, with the Instruqt CLI: run `instruqt lab format` and then `instruqt lab validate` from this folder before pushing. `validate` checks HCL and resource references, but it does **not** run task scripts, so always playtest.

Docs: [Integrating external VCS](https://docs.labs.instruqt.com/version-control/integrating-external-vcs) · [Testing & validation](https://docs.labs.instruqt.com/development/testing)

---

## Repository layout

```
randomizers-lab/
├── main.hcl            # lab resource: settings + 7 chapters
├── sandbox.hcl         # the 5 randomizers (6 resources) + network + 2 containers
├── tabs.hcl            # 2 terminals, editor, cheat-sheet note
├── layouts.hcl         # instructions (40%) | tabs (60%)
├── pages.hcl           # 7 pages, page variables + activities
├── tasks.hcl           # 6 tasks / 11 conditions (check + solve)
├── quizzes.hcl         # 6 quizzes / 15 questions
├── outputs.hcl         # non-secret outputs
├── instructions/       # 01-welcome.md … 07-capstone.md
├── notes/cheatsheet.md # always-on reference tab
├── files/bin/          # startup.sh (workstation entrypoint), lab-values helper
└── scripts/task/<task>/check*.sh, solve*.sh
```

## Learner flow

| # | Page | Task (conditions) | Quiz |
|---|---|---|---|
| 1 | Mission Briefing | – | – |
| 2 | random_creature | `creature_badge`: badge.txt matches, hostname resolves | 2 questions |
| 3 | random_number | `find_port`: port.txt matches and is in range, port answers | 2 questions |
| 4 | random_password | `unlock_vault`: `vault:pin` = PIN (auth via `REDISCLI_AUTH`) | 2 questions |
| 5 | random_uuid | `register_session`: hash `session:<uuid>`, version digit | 2 questions |
| 6 | random_id | `tenant_namespace`: `tenant:<hex>` = dec, base64 decodes to hex | 2 questions |
| 7 | Capstone | `deploy_shards`: exactly N shard keys, manifest with **no secrets** | 5 questions |

---

## Design decisions (and why)

These come from the docs, plus field reports in Slack `#2-point-0-internal-feedback` and support threads.

1. **Task scripts are strict POSIX `sh`.** The task runner executes scripts as `sh -c <contents>`, whatever the shebang says. Bash-only syntax (`set -o pipefail`, `[[ ]]`, arrays) fails on Debian's `dash`.
2. **Checks never hard-code a random value.** Each script reads the expected value from the workstation's environment and falls back to `/proc/1/environ` (the container's PID 1 environment, where `sandbox.hcl` injected it). The same script works for every learner.
3. **No `template`, `copy` or `exec` resources.** A teammate's Labs 2.0 test repo flagged `template` and `copy` as "Post GA", and `exec` against Debian images failed there. Values travel through `environment`, page `variables` and a read-only `files/` volume mount instead, the pattern an Instruqt engineer recommended for replacing execs.
4. **Page variables are camelCase.** The web UI instructions editor has been seen escaping underscores in placeholders (`{{mgw\_docs\_version}}`), which breaks playback.
5. **`random_password` uses `min_*`.** A customer lab using `length = 16, special = false` with no minimums failed about 6% of starts, because (52/62)^16 of passwords had no digit and the identity provider rejected them. The lab teaches this case directly.
6. **`override_special = "@#%+="`.** It keeps the password shell-safe, which matters because the vault's health check and `--requirepass` receive it.
7. **Secrets never reach instructions or outputs.** The password and PIN go only to container `environment`. The capstone check fails if either appears in the manifest.
8. **`lower()` on the creature name.** Hostnames stay predictable whatever casing the generator returns. (Upstream Jumppad capitalizes creature names, for example `Zesty-Kraken`, while the Instruqt docs show `brave-dolphin`.) Checks accept either form.
9. **`depends_on` + `health_check`.** The workstation starts only after the vault answers `PONG` on its random port.
10. **The literal `{{` trick.** Pages that need to *show* placeholder syntax get a variable `lb = "{{"` and write `{{lb}}creature}}`, so nothing is rendered by accident.

## Testing checklist

- [ ] Sync status **Success** after import
- [ ] Sandbox starts; **Workstation** prompt shows the creature name
- [ ] `lab-values` prints every value; `LAB_TENANT_B64` is **not** `<empty>`
- [ ] Welcome page table shows real values, not empty cells or raw `{{…}}`
- [ ] Each task **fails** first (click Check before doing anything), then passes after the steps
- [ ] Each task's **Solve** (skip) completes it
- [ ] Capstone: adding `VAULT_PASSWORD=...` to `manifest.env` makes the check fail
- [ ] Completion message shows your creature name

## Troubleshooting

| Symptom | Likely cause / fix |
|---|---|
| `Unsupported attribute "base64"` on start | Your platform version doesn't expose `random_id.base64`. Remove the `LAB_TENANT_B64` line in `sandbox.hcl` and `tenantB64` in `pages.hcl`. The decode check falls back to hex. |
| Workstation fails to start / `lab-values: not found` | The `files` volume didn't mount. Check the path `source = "files"` relative to `sandbox.hcl`. |
| Vault never healthy | Check the vault container logs. The health check runs `redis-cli -p <port> -a '<password>' ping`. |
| Check fails with `sh: … Illegal option` | A script picked up a bash-ism. Keep them POSIX. |
| Instructions show blank values | A page variable references an attribute that's empty. Compare with `lab-values`. |
| Push not reflected in the lab | Check **Project settings → Version control** and the sync status. |

## References

- Randomizers: [random_creature](https://docs.labs.instruqt.com/reference/sandbox/utilities/random/randomcreature/) · [random_id](https://docs.labs.instruqt.com/reference/sandbox/utilities/random/randomid/) · [random_number](https://docs.labs.instruqt.com/reference/sandbox/utilities/random/randomnumber/) · [random_password](https://docs.labs.instruqt.com/reference/sandbox/utilities/random/randompassword/) · [random_uuid](https://docs.labs.instruqt.com/reference/sandbox/utilities/random/randomuuid/)
- Content: [lab](https://docs.labs.instruqt.com/reference/content/lab/) · [page](https://docs.labs.instruqt.com/reference/content/page/) · [task](https://docs.labs.instruqt.com/reference/content/task/) · [layout](https://docs.labs.instruqt.com/reference/content/layout/) · [note](https://docs.labs.instruqt.com/reference/content/note/) · [quiz](https://docs.labs.instruqt.com/reference/content/quiz/quiz/)
- Sandbox: [container](https://docs.labs.instruqt.com/reference/sandbox/compute/container/) · [terminal](https://docs.labs.instruqt.com/reference/sandbox/ui/terminal/) · [editor](https://docs.labs.instruqt.com/reference/sandbox/ui/editor/) · [string functions](https://docs.labs.instruqt.com/reference/functions/string/)
