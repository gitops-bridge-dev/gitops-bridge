import os
import glob
import yaml
import sys
import subprocess
from packaging import version
from packaging.version import InvalidVersion
import requests


def compare_versions(current_version, latest_version, chart_name):
    # Compare the versions
    # print(f"Comparing versions for {chart_name}")
    # print(f"Current version: {current_version}")
    # print(f"Latest version: {latest_version}")
    # prefix latest_version with v if it's not already
    # convert latest_version to string
    cmp_latest_version = f'{str(latest_version)}'
    if not cmp_latest_version.startswith('v'):
        cmp_latest_version = 'v' + str(latest_version)
    if latest_version and version.parse(cmp_latest_version) > version.parse(current_version):
        print(
            f"Newer version available for {chart_name}: {latest_version} (current: {current_version})")
        # if current_version starts with 'v' make sure that return value also start with a single 'v'
        if current_version.startswith('v') and not f'{str(latest_version)}'.startswith('v'):
            return 'v' + str(latest_version)
        return str(latest_version)
    else:
      print(f"No newer version available for {chart_name} (current: {current_version})")
    return None


def extract_values(yaml_file):
    addon_chart_repository_namespace = None
    with open(yaml_file, 'r') as file:
        print(f"Extracting values from {yaml_file}")
        content = yaml.safe_load(file)
        try:
            addon_chart = content['spec']['generators'][0]['merge']['generators'][0]['clusters']['values']['addonChart']
            addon_chart_version = content['spec']['generators'][0]['merge'][
                'generators'][0]['clusters']['values']['addonChartVersion']
            addon_chart_repository = content['spec']['generators'][0]['merge'][
                'generators'][0]['clusters']['values']['addonChartRepository']
            # check for addonChartRepositoryNamespace without creating an exception if key is not present
            # check if content contains addonChartRepositoryNamespace
            if 'addonChartRepositoryNamespace' in content['spec']['generators'][0]['merge']['generators'][0]['clusters']['values']:
                addon_chart_repository_namespace = content['spec']['generators'][0]['merge'][
                'generators'][0]['clusters']['values']['addonChartRepositoryNamespace']
                # check if addon_chart_repository_namespace is a None value, if it is, then set it to empty string

            if addon_chart_repository_namespace is None:
                addon_chart_repository_namespace = ""
            # print the four return values before returning
            # print(f"addon_chart: {addon_chart}")
            # print(f"addon_chart_version: {addon_chart_version}")
            # print(f"addon_chart_repository: {addon_chart_repository}")
            # print(f"addon_chart_repository_namespace: {addon_chart_repository_namespace}")

            return addon_chart, addon_chart_version, addon_chart_repository, addon_chart_repository_namespace
        except (KeyError, TypeError):
            print(f"Unable to extract values from {yaml_file}")
            return None, None, None, None


def check_newer_version(repo_url, chart_name, current_version):
    # Remove the repository
    subprocess.run(['helm', 'repo', 'remove', 'temp_repo'],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    # Add the repository
    subprocess.run(['helm', 'repo', 'add', 'temp_repo', repo_url],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    # Update the repository
    # hide output to not spam the console
    subprocess.run(['helm', 'repo', 'update'],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    # Fetch the latest version of the chart
    # print(f"Fetching latest version for {chart_name} from {repo_url}")
    latest_version_output = subprocess.getoutput(
         f'helm search repo temp_repo/{chart_name} -o yaml')
    parsed_output = yaml.safe_load(latest_version_output)
    latest_version = parsed_output[0]['version']
    # print(f"Current version for {chart_name}: {current_version}")

    update_version = compare_versions(
        current_version, latest_version, chart_name)
    # Remove the repository
    subprocess.run(['helm', 'repo', 'remove', 'temp_repo'],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return update_version


def check_newer_version_from_github(owner, repo, current_version):
    latest_version = get_latest_github_release_version(owner, repo)
    # print(f"Current version for {owner}/{repo}: {current_version}")
    # print(f"Latest release version for {owner}/{repo}: {latest_version}")
    return compare_versions(current_version, latest_version, repo)


def get_latest_github_release_version(owner, repo):
    url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
    response = requests.get(url)

    if response.status_code != 200:
        print(
            f"Error fetching latest release for {owner}/{repo}: {response.status_code}")
        return None

    release_info = response.json()
    return release_info.get("tag_name", None)

# write function to update the version in the yaml file with updated version


def update_version(yaml_file, current_version, update_version):
    # If update_version is not None, update the version in the yaml file
    if update_version is None:
        return None
    # update the yaml_file without parsing as yaml, and just find current_version and replace it with update_version without changing anything about the file
    with open(yaml_file, 'r') as file:
        lines = file.readlines()
        # Replace the current_version with the update_version in each line
        updated_lines = [line.replace(current_version, update_version) for line in lines]
    # Write the updated lines back to the file
    with open(yaml_file, 'w') as file:
        file.writelines(updated_lines)


# main
if len(sys.argv) < 2:
    print("Please provide the directory path as an argument.")
    sys.exit(1)


def extract_provider_values(yaml_file):
    with open(yaml_file, 'r') as file:
        content = yaml.safe_load(file)
        try:
            provider_name = content['provider']['metadata']['name']
            provider_version = content['provider']['package']['version']
            provider_registry = content['provider']['package']['registry']
            return provider_name, provider_version, provider_registry
        except (KeyError, TypeError):
            #print(f"Unable to extract values from {yaml_file}")
            try:
                provider_name = content['global']['aws_upbound_registry']
                provider_version = content['global']['aws_upbound_version']
                provider_registry = content['global']['aws_upbound_registry']
                return provider_name, provider_version, f'{provider_registry}/provider-family-aws'
            except (KeyError, TypeError):
                #print(f"Unable to extract values from {yaml_file}")
                return None, None, None


def check_newer_version_from_oci(provider_name, provider_registry, provider_version):
    # Execute the command and get the output
    print(f'provider_registry: {provider_registry}')
    print(f'provider_name: {provider_name}')
    print(f'provider_version: {provider_version}')
    result = subprocess.getoutput(f'crane ls {provider_registry}')

    # Split the output by lines and parse the versions
    # remove any line that cause an exception InvalidVersion
    # iterate over evey line try version.parse with a try except block
    # if the version.parse doesn't throw an exception, then add the line to the result
    # if the version.parse throws an exception, then do nothing
    new_result = ''
    for line in result.strip().split('\n'):
        try:
            # if provider_name is karpenter ignore if the line does not start with 'v'
            if provider_name == 'karpenter' and not line.startswith('v'):
                continue
            # line contains '-stable; ignore
            if '-stable' in line:
                continue
            # line contains '-rc' ignore
            if '-rc.' in line:
                continue
            version.parse(line)
            new_result += f'{line}\n'
        except (InvalidVersion):
            continue

    # if new_result is empty, then return None
    if new_result == '':
        return provider_version
    # print new_result
    # print(f'new_result: {new_result}')

    # Split the output by lines and parse the versions
    versions = [version.parse(v) for v in new_result.strip().split('\n')]

    # Find the latest version
    latest_version = max(versions)

    update_version = compare_versions(
        provider_version, latest_version, provider_name)

    return update_version


directory_path = sys.argv[1]
yaml_files = glob.glob(os.path.join(
    directory_path, '**/crossplane/**/values.yaml'), recursive=True)

for yaml_file in yaml_files:
    #print(f'processing file {yaml_file}')
    provider_name, provider_version, provider_registry = extract_provider_values(
        yaml_file)
    if provider_name is not None:
        update_version(yaml_file, provider_version, check_newer_version_from_oci(provider_name, provider_registry, provider_version))


directory_path = sys.argv[1]
yaml_files = glob.glob(os.path.join(
    directory_path, '**/*.yaml'), recursive=True)

for yaml_file in yaml_files:
    # continue if the yaml_file doesn't contain the line kind: ApplicationSet
    with open(yaml_file, 'r') as file:
        try:
            content = yaml.safe_load(file)
            if content['kind'] != 'ApplicationSet':
                continue
        except (KeyError, TypeError, yaml.YAMLError):
            # print(f"Unable to extract values from {yaml_file}")
            continue
    addon_chart, addon_chart_version, addon_chart_repository, addon_chart_repository_namespace = extract_values(
        yaml_file)
    if addon_chart is not None:
        # make the following a switch statement
        if addon_chart_repository == "public.ecr.aws":
            update_version(yaml_file, addon_chart_version,check_newer_version_from_oci(addon_chart, addon_chart_repository+"/"+addon_chart_repository_namespace+"/"+addon_chart, addon_chart_version))
            continue
        update_version(yaml_file, addon_chart_version, check_newer_version(
            addon_chart_repository, addon_chart, addon_chart_version))
