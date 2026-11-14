package LRD_Metadata {
    doc /*
     * Project metadata used on every requirement: where it comes from in the specs, and how
     * it relates to the original wording (kept, reworded, split or new).
     */

    private import ScalarValues::String;

    metadata def SpecSource {
        attribute reference : String;
        attribute basis : String;
    }
}
