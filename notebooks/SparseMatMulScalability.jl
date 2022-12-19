### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ e42a3f88-7fb8-11ed-2b3a-ed9befa26d9d
begin
	@quickactivate "ClusterBenchmarks"
	using BSON
	using CSV
	using DataFrames
	using DrWatson
	using Plots
end

# ╔═╡ 7e0f9b1e-8980-4711-af2d-46bca71aac1f
collect_results(projectdir("test"))

# ╔═╡ 723abba6-47ca-4d28-8881-4b325336ee6d


# ╔═╡ Cell order:
# ╠═e42a3f88-7fb8-11ed-2b3a-ed9befa26d9d
# ╠═7e0f9b1e-8980-4711-af2d-46bca71aac1f
# ╠═723abba6-47ca-4d28-8881-4b325336ee6d
