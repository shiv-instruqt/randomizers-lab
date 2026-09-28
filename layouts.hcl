resource "layout" "main" {
  column {
    width = "40"

    instructions {
      title = "Instructions"
    }
  }

  column {
    width = "60"

    tab "workstation" {
      title  = "Workstation"
      target = resource.terminal.workstation
      active = true
    }

    tab "vault" {
      title  = "Vault Server"
      target = resource.terminal.vault
    }

    tab "editor" {
      title  = "Editor"
      target = resource.editor.workspace
    }

    tab "cheatsheet" {
      title  = "Cheat Sheet"
      target = resource.note.cheatsheet
    }
  }
}
