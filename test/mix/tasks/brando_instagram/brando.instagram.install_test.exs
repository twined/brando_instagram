Code.require_file "../../../support/mix_helper.exs", __DIR__

defmodule Mix.Tasks.BrandoInstagram.InstallTest do
  use ExUnit.Case, async: true

  import MixHelper

  @app_name  "photo_blog"
  @tmp_path  tmp_path()
  @project_path Path.join(@tmp_path, @app_name)

  setup_all do
    templates_path = Path.join([@project_path, "deps",
                               "brando_portfolio", "web", "templates"])
    root_path =  File.cwd!

    # Clean up
    File.rm_rf @project_path

    # Create path for app
    File.mkdir_p Path.join(@project_path, "web")

    # Create path for templates
    File.mkdir_p templates_path

    # Copy templates into `deps/?/templates`
    # to mimic a real Phoenix application
    File.cp_r! Path.join([root_path, "web", "templates"]), templates_path

    # Move into the project directory to run the generator
    File.cd! @project_path
  end

  test "brando.portfolio.install" do
    Mix.Tasks.BrandoInstagram.Install.run([])
    assert_received {:mix_shell, :info, ["\nBrando Instagram finished installing."]}

    assert [migration_file] =
      Path.wildcard("priv/repo/migrations/*_create_instagram_instagramimages.exs")

    assert_file migration_file, fn file ->
      assert file =~ "defmodule BrandoInstagram.Repo.Migrations.CreateInstagramimages"
    end

    assert_file "web/static/js/admin/instagram.js", fn file ->
      assert file =~ "class Instagram {"
    end
  end
end
