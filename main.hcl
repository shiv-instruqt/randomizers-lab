resource "lab" "main" {
  title       = "Operation Randomize: Hands-on with Labs 2.0 Randomizers"
  description = "Build a one-of-a-kind sandbox with all five Labs 2.0 randomizers - random_creature, random_number, random_password, random_uuid and random_id. You will find a vault by its creature hostname and random port, unlock it with a generated password, register a UUID session, carve out a random_id tenant namespace, and finish with a capstone that ties them all together."
  layout      = resource.layout.main

  settings {
    theme = "modern-dark"

    timelimit {
      duration   = "1h"
      extend     = "30m"
      show_timer = true
    }

    idle {
      enabled      = true
      timeout      = "20m"
      show_warning = true
    }
  }

  content {
    chapter "intro" {
      title = "Mission Briefing"

      page "welcome" {
        reference = resource.page.welcome
      }
    }

    chapter "creature" {
      title = "random_creature"

      page "creature" {
        reference = resource.page.creature
      }
    }

    chapter "number" {
      title = "random_number"

      page "number" {
        reference = resource.page.number
      }
    }

    chapter "password" {
      title = "random_password"

      page "password" {
        reference = resource.page.password
      }
    }

    chapter "uuid" {
      title = "random_uuid"

      page "uuid" {
        reference = resource.page.uuid
      }
    }

    chapter "id" {
      title = "random_id"

      page "id" {
        reference = resource.page.id
      }
    }

    chapter "capstone" {
      title = "Capstone"

      page "capstone" {
        reference = resource.page.capstone
      }
    }
  }
}
