# list all simulations
SIMULATIONS, = glob_wildcards("{simulation_rep}/production/production.gro")

rule water_rdf:
    """Calculate water RDF"""
    input: "{simulation_rep}/production/production.gro"
    output: "{simulation_rep}/analysis/water_rdf.csv"
    run:
        system = mda.Universe(input[0])
        water = system.select_atoms('resname W')

        rdf_data = rdf.InterRDF(
            water,
            water,
            nbins=75,
            range=(0.0, 15.0),
            # nbins = config['rdf_params']['nbins'],
            # range=(config['rdf_params']['range_start'], config['rdf_params']['range_end']),
            exclusion_block=(1,1)
        )

        rdf_data.run()

        rdf_data = pd.DataFrame(
            {
                'bins': rdf_data.results.bins,
                'rdf': rdf_data.results.rdf
            }
        )

        rdf_data.to_csv(output[0], index=False)


rule aggregate_water_rdf:
    """Plot water RDF from all simulations"""
    input: 
        expand(
            "{simulation_replicate}/analysis/water_rdf.csv",
            simulation_replicate = SIMULATIONS
        )
    output: 'water_rdf.csv'
    run:
        
        # load all results in a single dataframe
        rdf_data = []
        for rdf_file in input:
            df = pd.read_csv(rdf_file)
            rep = rdf_file.split('/')[1]
            df['rep'] = rep
            rdf_data.append(df)
        rdf_data = pd.concat(rdf_data, ignore_index=True)

        rdf_data.to_csv(output[0], index=False)
