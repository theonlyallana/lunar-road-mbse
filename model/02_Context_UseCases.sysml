package LRD_Context {
    doc /*
     * Mission context and use cases for the Lunar Road Demo MVP.
     * The demo is complete when a viewer can run both cases, change the road
     * assumptions and see how the result changes.
     */

    public import LRD_Structure::*;

    use case def 'Compare Trip With And Without Road' {
        subject sim : LunarRoadDemoSystem;
        actor viewer : DemoViewer;
        actor terrain : LunarTerrain;
        actor ephemeris : SunAndEarthEphemeris;
        objective {
            doc /* Show the difference a road makes to the same VIPER-class trip in time,
                 * energy, risk and reliability, on real south polar terrain. */
        }
    }

    use case def 'Change Road Assumptions' {
        subject sim : LunarRoadDemoSystem;
        actor viewer : DemoViewer;
        objective {
            doc /* Switch road on or off, pick the half, expected or high road preset, and pick
                 * a 150 W, 250 W or 350 W awake load, then see results update from the stored run set. */
        }
    }

    use case def 'Inspect Run Results' {
        subject sim : LunarRoadDemoSystem;
        actor viewer : DemoViewer;
        objective {
            doc /* Read arrival time, distance, energy used, minimum state of charge, time in shadow,
                 * waiting time, peak slip and pass or fail for each run. */
        }
    }

    use case 'run the demo' : 'Compare Trip With And Without Road' {
        first start;
        then include use case 'change assumptions' : 'Change Road Assumptions';
        then include use case 'inspect results' : 'Inspect Run Results';
        then done;
    }
}
