#!/usr/bin/env node
/**
 * Aggregates OpenAPI specs from all microservices through the API Gateway
 * into a single unified OpenAPI specification.
 */

const GATEWAY_URL = process.env.GATEWAY_URL || 'http://localhost:5000';

const SERVICES = [
  { name: 'sale', path: '/swagger-docs/sale/v1/swagger.json' },
  { name: 'approval', path: '/swagger-docs/approval/v1/swagger.json' },
  { name: 'payroll', path: '/swagger-docs/payroll/v1/swagger.json' },
  { name: 'inventory', path: '/swagger-docs/inventory/v1/swagger.json' },
  { name: 'manufacture', path: '/swagger-docs/manufacture/v1/swagger.json' },
  { name: 'identity', path: '/swagger-docs/identity/v1/swagger.json' },
];

async function fetchServiceSpec(service) {
  const url = `${GATEWAY_URL}${service.path}`;
  try {
    const response = await fetch(url, { signal: AbortSignal.timeout(5000) });
    if (!response.ok) {
      console.warn(`⚠ ${service.name}: ${response.status} ${response.statusText}`);
      return null;
    }
    const spec = await response.json();
    console.log(`✓ ${service.name}: ${Object.keys(spec.paths || {}).length} endpoints`);
    return { service, spec };
  } catch (error) {
    console.warn(`⚠ ${service.name}: ${error.message}`);
    return null;
  }
}

function mergeSpecs(results) {
  const merged = {
    openapi: '3.0.1',
    info: {
      title: 'Medion API Gateway',
      description: 'Unified API gateway for all Medion microservices',
      version: 'v1',
    },
    paths: {},
    components: {
      schemas: {},
      securitySchemes: {},
    },
    tags: [],
  };

  for (const result of results) {
    if (!result) continue;
    const { service, spec } = result;

    // Merge paths with service prefix
    if (spec.paths) {
      for (const [path, pathItem] of Object.entries(spec.paths)) {
        // Add service tag to all operations
        const taggedPathItem = { ...pathItem };
        for (const method of ['get', 'post', 'put', 'patch', 'delete', 'options', 'head']) {
          if (taggedPathItem[method]) {
            taggedPathItem[method] = {
              ...taggedPathItem[method],
              tags: [service.name, ...(taggedPathItem[method].tags || [])],
            };
          }
        }
        // Add /api/{service} prefix to paths to match API Gateway routing
        const prefixedPath = `/api/${service.name}${path === '/' ? '' : path}`;
        merged.paths[prefixedPath] = taggedPathItem;
      }
    }

    // Merge schemas (prefix with service name to avoid conflicts, sanitize names)
    if (spec.components?.schemas) {
      for (const [name, schema] of Object.entries(spec.components.schemas)) {
        const sanitizedName = sanitizeSchemaName(`${capitalize(service.name)}_${name}`);
        merged.components.schemas[sanitizedName] = schema;
        
        // Update $ref references in paths and schemas
        updateRefs(merged.paths, `#/components/schemas/${name}`, `#/components/schemas/${sanitizedName}`);
        updateRefs(schema, `#/components/schemas/${name}`, `#/components/schemas/${sanitizedName}`);
      }
    }

    // Merge security schemes
    if (spec.components?.securitySchemes) {
      Object.assign(merged.components.securitySchemes, spec.components.securitySchemes);
    }

    // Add service tag
    merged.tags.push({
      name: service.name,
      description: `${capitalize(service.name)} API`,
    });
  }

  // Clean up empty components
  if (Object.keys(merged.components.schemas).length === 0) {
    delete merged.components.schemas;
  }
  if (Object.keys(merged.components.securitySchemes).length === 0) {
    delete merged.components.securitySchemes;
  }
  if (Object.keys(merged.components).length === 0) {
    delete merged.components;
  }

  return merged;
}

function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

/**
 * Sanitize schema name to match OpenAPI spec pattern: ^[a-zA-Z0-9\.\-_]+$
 * Removes or replaces invalid characters like <, >, etc.
 */
function sanitizeSchemaName(name) {
  return name
    .replace(/<>/g, '')           // Remove empty generic brackets
    .replace(/</g, '_')           // Replace < with _
    .replace(/>/g, '_')           // Replace > with _
    .replace(/[^a-zA-Z0-9.\-_]/g, '_')  // Replace any other invalid chars
    .replace(/_+/g, '_')          // Collapse multiple underscores
    .replace(/^_|_$/g, '');       // Trim leading/trailing underscores
}

function updateRefs(obj, oldRef, newRef) {
  if (typeof obj !== 'object' || obj === null) return;
  
  for (const [key, value] of Object.entries(obj)) {
    if (key === '$ref' && value === oldRef) {
      obj[key] = newRef;
    } else if (typeof value === 'object') {
      updateRefs(value, oldRef, newRef);
    }
  }
}

async function main() {
  console.log(`Fetching OpenAPI specs from ${GATEWAY_URL}...\n`);

  const results = await Promise.all(SERVICES.map(fetchServiceSpec));
  const successCount = results.filter(Boolean).length;

  if (successCount === 0) {
    console.error('\n✗ No services responded. Is the gateway running?');
    process.exit(1);
  }

  console.log(`\nMerging ${successCount} service specs...`);
  const merged = mergeSpecs(results);

  const outputPath = new URL('../openapi-spec.json', import.meta.url);
  const { writeFileSync } = await import('node:fs');
  writeFileSync(outputPath, JSON.stringify(merged, null, 2));

  console.log(`\n✓ Generated openapi-spec.json with ${Object.keys(merged.paths).length} endpoints`);
}

main().catch((err) => {
  console.error('Error:', err.message);
  process.exit(1);
});
