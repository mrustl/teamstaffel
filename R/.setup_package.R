pkg <- list(
  name = "teamstaffel",
  title = "R Package for Visualising Results from BWB Teamstaffel",
  desc = paste(
    "R Package for Visualising Results from BWB Teamstaffel."
  )
)

kwb.pkgbuild::use_pkg_skeleton("teamstaffel")

kwb.pkgbuild::use_pkg(
  pkg = pkg,
  copyright_holder = list(name = "Michael Rustler", start_year = NULL),
  user = "mrustl"
)

kwb.pkgbuild::use_ghactions()

kwb.pkgbuild::create_empty_branch_ghpages("teamstaffel", org = "mrustl")

usethis::use_pipe()
usethis::use_vignette("Results_2022")
desc::desc_normalize()
