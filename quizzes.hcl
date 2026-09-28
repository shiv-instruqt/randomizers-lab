# -----------------------------------------------------------------------------
# random_creature
# -----------------------------------------------------------------------------
resource "single_choice_question" "creature_use" {
  question = "Which job is random_creature best suited for?"
  answer   = "A human-readable name for a resource, such as a hostname or label"

  distractors = [
    "A database password",
    "An API signing key",
    "A globally unique primary key",
  ]

  hints = ["Think about who reads the value - a person or a machine?"]
  tags  = ["random_creature"]
}

resource "single_choice_question" "creature_attr" {
  question = "Which attribute holds the generated name of resource \"random_creature\" \"mascot\" {}?"
  answer   = "resource.random_creature.mascot.value"

  distractors = [
    "resource.random_creature.mascot.name",
    "resource.random_creature.mascot.result",
    "resource.random_creature.mascot.id",
  ]

  tags = ["random_creature"]
}

resource "quiz" "creature" {
  questions = [
    resource.single_choice_question.creature_use,
    resource.single_choice_question.creature_attr,
  ]

  show_hints   = true
  show_answers = true
}

# -----------------------------------------------------------------------------
# random_number
# -----------------------------------------------------------------------------
resource "numeric_answer_question" "number_min" {
  question = "A random_number has minimum = 20000 and maximum = 29999. What is the smallest value it can ever generate?"
  answer   = 20000

  hints = ["The docs say the generated value will be >= minimum."]
  tags  = ["random_number"]
}

resource "single_choice_question" "number_type" {
  question = "random_number.value is a number. Which expression puts it into a container's environment map (map of strings)?"
  answer   = "\"$${resource.random_number.vault_port.value}\" (string interpolation)"

  distractors = [
    "resource.random_number.vault_port.value.string",
    "tostring(resource.random_number.vault_port.value) - not available in Labs 2.0",
    "Numbers cannot be used in environment variables",
  ]

  tags = ["random_number"]
}

resource "quiz" "number" {
  questions = [
    resource.numeric_answer_question.number_min,
    resource.single_choice_question.number_type,
  ]

  show_hints   = true
  show_answers = true
}

# -----------------------------------------------------------------------------
# random_password
# -----------------------------------------------------------------------------
resource "multiple_choice_question" "password_policy" {
  question = "A target system requires an uppercase letter, a lowercase letter and a digit in every password. Which settings guarantee that for random_password?"

  answer = [
    "min_upper = 1",
    "min_lower = 1",
    "min_numeric = 1",
  ]

  distractors = [
    "special = false",
    "length = 64",
    "override_special = \"@#\"",
  ]

  hints = [
    "Enabling a character class only makes it possible - not guaranteed.",
    "Look for the fields that set a floor per character class.",
  ]

  tags = ["random_password"]
}

resource "single_choice_question" "password_special" {
  question = "What does override_special = \"@#%+=\" do?"
  answer   = "Restricts special characters to exactly @ # % + ="

  distractors = [
    "Adds @ # % + = on top of the default special characters",
    "Removes @ # % + = from the password",
    "Forces every password to start with a special character",
  ]

  tags = ["random_password"]
}

resource "quiz" "password" {
  questions = [
    resource.multiple_choice_question.password_policy,
    resource.single_choice_question.password_special,
  ]

  show_hints   = true
  show_answers = true
}

# -----------------------------------------------------------------------------
# random_uuid
# -----------------------------------------------------------------------------
resource "single_choice_question" "uuid_version" {
  question = "In an RFC 4122 version 4 UUID like 550e8400-e29b-41d4-a716-446655440000, what is always the first character of the third group?"
  answer   = "4"

  distractors = ["0", "a", "It is random"]

  hints = ["The name of the UUID version is a clue."]
  tags  = ["random_uuid"]
}

resource "single_choice_question" "uuid_short" {
  question = "Which HCL expression derives an 8-character short ID from a random_uuid?"
  answer   = "substr(resource.random_uuid.session.value, 0, 8)"

  distractors = [
    "substr(resource.random_uuid.session.value, 8)",
    "resource.random_uuid.session.value[0:8]",
    "left(resource.random_uuid.session.value, 8)",
  ]

  tags = ["random_uuid"]
}

resource "quiz" "uuid" {
  questions = [
    resource.single_choice_question.uuid_version,
    resource.single_choice_question.uuid_short,
  ]

  show_hints   = true
  show_answers = true
}

# -----------------------------------------------------------------------------
# random_id
# -----------------------------------------------------------------------------
resource "numeric_answer_question" "id_hex_len" {
  question = "A random_id has byte_length = 6. How many characters long is its hex attribute?"
  answer   = 12

  hints = ["The docs: hex encoding will be twice the byte length."]
  tags  = ["random_id"]
}

resource "single_choice_question" "id_vs_password" {
  question = "You need a secret credential for a database. Per the docs, which randomizer should you use?"
  answer   = "random_password"

  distractors = ["random_id", "random_creature", "random_number"]

  hints = ["The random_id docs reserve it for non-sensitive data."]
  tags  = ["random_id", "random_password"]
}

resource "quiz" "id" {
  questions = [
    resource.numeric_answer_question.id_hex_len,
    resource.single_choice_question.id_vs_password,
  ]

  show_hints   = true
  show_answers = true
}

# -----------------------------------------------------------------------------
# Final - pick the right randomizer
# -----------------------------------------------------------------------------
resource "single_choice_question" "final_port" {
  question = "You run several copies of a service and want each lab to use a different port between 10000 and 20000."
  answer   = "random_number"

  distractors = ["random_id", "random_uuid", "random_creature"]
  tags        = ["final"]
}

resource "single_choice_question" "final_bucket" {
  question = "A cloud storage bucket name must be globally unique across every lab instance ever started."
  answer   = "random_uuid"

  distractors = ["random_creature", "random_number", "random_password"]
  tags        = ["final"]
}

resource "single_choice_question" "final_label" {
  question = "Learners should be able to say their environment's name out loud during a live workshop."
  answer   = "random_creature"

  distractors = ["random_uuid", "random_id", "random_password"]
  tags        = ["final"]
}

resource "single_choice_question" "final_suffix" {
  question = "You need a short, non-secret suffix for resource names and want it available as hex and decimal."
  answer   = "random_id"

  distractors = ["random_password", "random_creature", "random_uuid"]
  tags        = ["final"]
}

resource "single_choice_question" "final_secret" {
  question = "An admin console needs a login secret that must contain at least two symbols."
  answer   = "random_password with min_special = 2"

  distractors = [
    "random_id with byte_length = 32",
    "random_uuid",
    "random_password with special = true",
  ]

  tags = ["final"]
}

resource "quiz" "final" {
  questions = [
    resource.single_choice_question.final_port,
    resource.single_choice_question.final_bucket,
    resource.single_choice_question.final_label,
    resource.single_choice_question.final_suffix,
    resource.single_choice_question.final_secret,
  ]

  show_hints   = false
  show_answers = true
}
