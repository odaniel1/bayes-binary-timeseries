
# Load packages, plan and functions into namespace
purrr::map(fs::dir_ls("./R",glob = "*.R"), ~source(.))

# turn the plan into action
make(plan)

# plot plan
vis_drake_graph(plan)
