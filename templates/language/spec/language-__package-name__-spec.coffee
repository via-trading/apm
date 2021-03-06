# If you want an example of language specs, check out:
# https://github.com/via/language-gfm/blob/master/spec/gfm-spec.coffee

describe "PackageName grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      via.packages.activatePackage("language-__package-name__")

    runs ->
      grammar = via.syntax.grammarForScopeName("source.__package-name__")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.__package-name__"
