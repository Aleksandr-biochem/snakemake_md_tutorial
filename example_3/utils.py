import pandas as pd
import MDAnalysis as mda

def lipid_z_thickness(system: mda.Universe) -> pd.DataFrame:
    """
    Calculate Z-thickness of sn1 tail in each POPC lipid molecule
    in a single MDAnalysis trajectory frame.

    Parameters
    ----------
    System : MDAnalysis.Universe
        Universe containing topology and trajectory.

    Returns
    -------
    pd.DataFrame
        Columns:
          - resid
          - z_min
          - z_max
          - z_thickness
    """

    
    lipids = system.select_atoms('resname POPC')
    z_thickness_data = []

    for res in lipids.residues:

        # use Sn1 tail
        atoms = system.select_atoms(f'resid {res.resid} and name GL1 ??A').atoms
        z = atoms.positions[:, 2].astype(float)
        z_min = min(z)
        z_max = max(z)

        z_thickness_data.append(
            {
                "resid": res.resid,
                "z_min": z_min,
                "z_max": z_max,
                "z_thickness": z_max - z_min,
            }
        )

    return pd.DataFrame(z_thickness_data)
