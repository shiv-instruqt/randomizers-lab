# Your main shell - everything in this lab happens here.
resource "terminal" "workstation" {
  target            = resource.container.workstation
  shell             = "/bin/bash"
  working_directory = "/root/workspace"
}

# A shell on the vault server itself, used to see how the random values
# arrived there (command line, network aliases).
resource "terminal" "vault" {
  target            = resource.container.vault
  shell             = "/bin/bash"
  working_directory = "/data"
}

# Browse and edit the files you create in /root/workspace.
resource "editor" "workspace" {
  workspace "workspace" {
    target    = resource.container.workstation
    directory = "/root/workspace"
  }
}

# Always-on reference for the five randomizers.
resource "note" "cheatsheet" {
  file = "notes/cheatsheet.md"
}
