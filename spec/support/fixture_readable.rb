def read_json_fixture(name)
  JSON.parse(
    File.read(
      Rails.root.join("spec/fixtures/#{name}.json")
    )
  )
end
