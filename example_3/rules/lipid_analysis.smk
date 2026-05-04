
rule analyse_lipids:
    """Calculate Z-thickness for each lipid in a frame"""
    input: "{simulation_rep}/production/production.gro"
    output: "{simulation_rep}/analysis/z_thickness.csv"
    run:
        # load system into MDAnalysis universe
        system = mda.Universe(input[0])

        # run calculation
        z_thickness_by_lipid = lipid_z_thickness(system)

        # save the output
        z_thickness_by_lipid.to_csv(output[0], index=False)


rule average_z_thickness:
    """Calculate mean Z-thickness of lipids in a frame"""
    input: "{simulation_rep}/analysis/z_thickness.csv"
    output: "{simulation_rep}/analysis/mean_z_thickness.txt"
    run:
        z_thickness_by_lipid = pd.read_csv(input[0])
        mean_z_thickness = z_thickness_by_lipid['z_thickness'].mean()

        with open(output[0], 'w') as f:
            f.write(str(mean_z_thickness))
