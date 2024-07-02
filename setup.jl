using Pkg

function ensure(package::String, commit::String="")
    # Check if the package is installed with the specific commit.
    if package_installed_at_commit(package, commit)
        println("$package at commit $commit is already installed.")
    else
        println("Installing $package at commit $commit...")
        if commit == ""
            Pkg.add(package)
        else
            Pkg.add(PackageSpec(name=package, rev=commit))
        end
    end
end

function package_installed_at_commit(package::String, commit::String)::Bool
    # Retrieve the package status
    pkgs = Pkg.status(; mode=Pkg.REPLMode.PkgStatusMode.PKGS)
    for pkg in pkgs
        if pkg.name == package
            if commit == "" || (commit != "" && startswith(pkg.revision, commit))
                return true
            end
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
