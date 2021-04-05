using GLMakie

function plot_agg(agglog::String; suffixes = ["energy", "sens", "repr", "speed"])
    df = CSV.File(agglog) |> DataFrame
    nspecies = maximum(df.species)
    gdf = groupby(df, :species)
    fig = Figure(resolution = (1600, 1000))
    cols = cgrad(:lighttest; alpha=0.4)
    

    plotline(ax, steps, data, color) = lines!(ax, steps, data; color, linewidth = 2)

    ax = fig[1, 1] = Axis(fig; ylabel = "Bact population")
    lines = [plotline(ax, gdf[i].step, gdf[i].nbact, cols[i/nspecies]) for i in 1:nspecies]

    for suffix in suffixes
        axm = fig[end+1, 1] = Axis(fig; ylabel = "Mean $suffix")
        axs = fig[end, 2] = Axis(fig; ylabel = "Std $suffix")

        for i in 1:nspecies
            plotline(axm, gdf[i].step, gdf[i][!, "μ_$suffix"], cols[i/nspecies])
            plotline(axs, gdf[i].step, gdf[i][!, "σ_$suffix"], cols[i/nspecies])
        end
    end
    fig
end

function plot_food(foodlog::String)
    fig = Figure(resolution = (600, 600))
    food = h5open(foodlog, "r")
    maxtime = size(food["log"], 1)
    time = Slider(fig[1, 1], range = 1:maxtime, startvalue = 1)
    cfood = @lift(food["log"][$(time.value), :, :])
    ax = fig[0, 1] = Axis(fig)
    heatmap!(ax, cfood)
    
    fig, food
end

function plot_agent_scatter(bactlog::String; params = ["sens"])
    df = CSV.File(bactlog; select = ["step", "species", params...]) |> DataFrame
    n_species = maximum(df.species)
    df = groupby(df, :species; sort = true)
    
    sp_cols = cgrad(:tab20; alpha=0.1)
    fig = Figure(resolution = (600, 600))
    for (ind, par) in enumerate(params)
        for i in 1:n_species
            ax = fig[ind, i] = Axis(fig; ylabel = par)
            xlims!(ax, (0, maximum(df[1].step)))
            scatter!(ax, df[i].step, df[i][!, par]; color = sp_cols[(i-1)/n_species], markersize = 4, strokewidth = 0)
        end
    end

    fig
end