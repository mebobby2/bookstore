# Bookstore

**TODO: Add description**

## Installation
```
mix deps.get
MIX_ENV="test" iex -S mix
```

```
Bookstore.DB.setup()
```

## IEX
Start:
```
MIX_ENV="test" iex -S mix
```

Load test files in iex:
```
ExUnit.start()
c "test/csv_test.exs"

:proper_gen.pick(CsvTest.csv_source())
:proper_check.sample(PbtGenerators.path())
:proper_types.term()
```

Or can also use :proper_gen and :proper_types
