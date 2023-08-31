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
	df[!,:used_memory_MB] = df[!,:total_memory_MB] - df[!,:free_memory_MB]
	df[!,:num_dofs_x_proc] = df[!,:num_dofs] .÷ df[!,:num_procs]
	sort!(df,:num_procs)
end

# ╔═╡ a572baad-a1be-465d-a048-aef8c0f80469
begin
	df.curated_time .= 1.e10
	for k in 1:200
		df.curated_time = min.(df.curated_time,map(x->x[:max],df[!,"time_$k"])) 
	end
	df.curated_time
end

# ╔═╡ 104d2142-0b9d-42ec-b84d-9225c8b32efc
begin
	plt1 = plot(xlabel="Num DoFs per proc, log2",ylabel="Allocations")
	for np in unique(df.num_procs)
		dfi = df[df.num_procs .== np,:]
		sort!(dfi,:num_dofs_x_proc)
		x = log2.(dfi.num_dofs_x_proc)
		allocs = dfi.allocated_fespaces_MB + dfi.allocated_system_MB + dfi.allocated_model_MB + dfi.allocated_measure_MB
		y = allocs .* 1.e-3 ./ np
		plot!(plt1,x,y,label="np = $np")
	end
	plt1
end

# ╔═╡ 0783858d-7ce3-4bf1-8b42-1275f35b95f8
begin
	plt2 = plot(xlabel="Num DoFs per proc, log2",ylabel="Time, log2")
	for np in unique(df.num_procs)
		dfi = df[df.num_procs .== np,:]
		sort!(dfi,:num_dofs_x_proc)
		x = log2.(dfi.num_dofs_x_proc)
		y = log2.(dfi.curated_time)
		plot!(plt2,x,y,label="np = $np")
		plot!(plt2,x,x.-x[end].+y[end],lc=:black,ls=:dot,label="")
	end
	plt2
end

# ╔═╡ f762c624-6c2f-4255-87b0-569068e5d5d1
begin
	plt3 = plot(xlabel="Num DoFs per proc, log2",ylabel="Allocations")
	for np in unique(df.num_procs)
		dfi = df[df.num_procs .== np,:]
		sort!(dfi,:num_dofs_x_proc)
		x = log2.(dfi.num_dofs_x_proc)
		y = (dfi.total_memory_MB .- dfi.free_memory_MB) * 1.e-3 ./ 48
		plot!(plt3,x,y,label="np = $np")
	end
	plt3
end

# ╔═╡ Cell order:
# ╠═e42a3f88-7fb8-11ed-2b3a-ed9befa26d9d
# ╠═7e0f9b1e-8980-4711-af2d-46bca71aac1f
# ╠═723abba6-47ca-4d28-8881-4b325336ee6d
# ╠═a572baad-a1be-465d-a048-aef8c0f80469
# ╠═104d2142-0b9d-42ec-b84d-9225c8b32efc
# ╠═0783858d-7ce3-4bf1-8b42-1275f35b95f8
# ╠═f762c624-6c2f-4255-87b0-569068e5d5d1
