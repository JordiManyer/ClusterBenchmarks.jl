### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ 107fb51e-4b93-11ee-25ac-775250858cbf
begin
	@quickactivate "ClusterBenchmarks"
	using BSON
	using CSV
	using DataFrames
	using DrWatson
	using Plots
end

# ╔═╡ 9b1b72ab-9a55-463e-8fe2-e3be9f408f80
df = collect_results(projectdir("experiments/AssemblyNeighbors/data"));

# ╔═╡ d238e6ef-f06c-45a2-9957-d62ec286d276
begin # Group by case
	gdf = groupby(df,:case);
	uni = gdf[(:uniform,)]; sort!(uni,:num_procs);
	all = gdf[(:all,)]; sort!(all,:num_procs);
end

# ╔═╡ 5a8b97e2-73a8-4ae9-b0f8-04412b9bf0c5
begin # uniform case
	f = log10
	#case = "all"; dfi = all;
	case = "uniform"; dfi = uni;
	algorithms = ["ibarrier","gatherscatter"]
	labels = ["iBarrier","Scatter-Gather"]

	lcolors = [:royalblue,:firebrick4]
	fcolors = [:lightskyblue1,:coral1]

	plt1 = plot(xlabel="Num Ranks",ylabel="Log10(t)")
	x  = dfi[!,:num_procs]

	for (alg,lc,fc,l) in zip(algorithms,lcolors,fcolors,labels)
		y = f.(dfi[!,"$(case)_$(alg)_tmean"])
		y_low = f.(dfi[!,"$(case)_$(alg)_tmin"])
		y_upp = f.(dfi[!,"$(case)_$(alg)_tmax"])
	
		plot!(plt1,x,y_low; fillrange=y_upp,label=nothing,linecolor=fc,fillcolor=fc)
		plot!(plt1,x,y,label=l,linecolor=lc)
	end
	savefig(plt1,"../figures/assembly_nbors_$case")
	plt1
end

# ╔═╡ Cell order:
# ╠═107fb51e-4b93-11ee-25ac-775250858cbf
# ╠═9b1b72ab-9a55-463e-8fe2-e3be9f408f80
# ╠═d238e6ef-f06c-45a2-9957-d62ec286d276
# ╠═5a8b97e2-73a8-4ae9-b0f8-04412b9bf0c5
