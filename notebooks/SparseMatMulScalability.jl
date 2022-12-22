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
df = collect_results(projectdir("experiments/SparseMatMulScalability/data"))

# ╔═╡ 723abba6-47ca-4d28-8881-4b325336ee6d
begin
	df[!,:used_memory] = df[!,:total_memory] - df[!,:free_memory]
	sort!(df,:num_procs)
end

# ╔═╡ e2f5dd1f-ac18-4964-9185-caf18ecdb35f
begin
	df[!,:ndofs] = [12582912,50331648,3145728,201326592,12582912,50331648]
	df[!,:ndofsxproc] = df[!,:ndofs] .÷ df[!,:num_procs]
end

# ╔═╡ 104d2142-0b9d-42ec-b84d-9225c8b32efc
begin
	plt = plot()
	for ndofs in sort(unique(df[!,:ndofsxproc]))
		if (Int(log2(ndofs)) != 18)
		dfi = df[df.ndofsxproc .== ndofs,:]
		sort!(dfi,:num_procs)
		x = dfi[!,:num_procs] .÷ 48
		y = map(x -> x[:max],dfi[!,:time_total]) ./ dfi[!,:num_procs]
		println(y)
		plot!(plt,x,y,label=log2(ndofs))
		end
	end
	plt
end

# ╔═╡ 0783858d-7ce3-4bf1-8b42-1275f35b95f8
begin
	plt2 = plot()
	for np in unique(df.num_procs)
		dfi = df[df.num_procs .== np,:]
		sort!(dfi,:ndofsxproc)
		x = log2.(dfi.ndofsxproc)
		y = map(x -> x[:max],dfi[!,:time_total])

		plot!(plt2,x,y./y[end],label=np)
	end
	plt2
end

# ╔═╡ Cell order:
# ╠═e42a3f88-7fb8-11ed-2b3a-ed9befa26d9d
# ╠═7e0f9b1e-8980-4711-af2d-46bca71aac1f
# ╠═723abba6-47ca-4d28-8881-4b325336ee6d
# ╠═e2f5dd1f-ac18-4964-9185-caf18ecdb35f
# ╠═104d2142-0b9d-42ec-b84d-9225c8b32efc
# ╠═0783858d-7ce3-4bf1-8b42-1275f35b95f8
