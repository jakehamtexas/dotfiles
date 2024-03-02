return {
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        "neotest-rust",
        "neotest-playwright",
        "neotest-jest",
      },
    },
    dependencies = {
      "rouge8/neotest-rust",
      "thenbe/neotest-playwright",
      "haydenmeade/neotest-jest",
    },
  },
}
