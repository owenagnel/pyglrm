using Pkg

function ensure(package::String, commit::String="")
    installed_packages = Dict{String, String}()
    for (name, info) in Pkg.dependencies()
        installed_packages[string(name)] = string(info.uuid)
    end

    if package ∉ keys(installed_packages) || !is_package_commit_installed(package, commit)
        println("Installing $package at commit $commit...")
        if commit == ""
            Pkg.add(package)
        else
            Pkg.add(PackageSpec(name=package, rev=commit))
        end
    else
        println("$package at commit $commit is already installed.")
    end
end

function is_package_commit_installed(package::String, commit::String)::Bool
    # Retrieve package status
    pkgs = Pkg.status(; mode=Pkg.REPLMode.PkgStatusMode.CLEAN)
    for pkg in pkgs
        if pkg.name == package && pkg.commit == commit
            return true
        end
    end
    return false
end

# Ensure that Julia is configured with the necessary packages.
ENV["PYTHON"] = ARGS[1]  # Setup using "current" version of Python.
ensure("LowRankModels", "e15afec")
ensure("NullableArrays")
ensure("FactCheck")
ensure("PyCall")

# This sets the version of the packages that are used.  In the long term it
# would be better to use built in Julia commands.  However, here we pin the
# versions to specific git commit numbers and thus perform this manually.
shell_file = ARGS[2]
run(`bash $shell_file`)

# Finally, we build the packages now since PyCall needs to be built with
# ENV["PYTHON"] set and LowRankModels takes so long that it may cause users to
# think the system is not working upon first use.
Pkg.build("LowRankModels") ; using LowRankModels
Pkg.build("PyCall")
