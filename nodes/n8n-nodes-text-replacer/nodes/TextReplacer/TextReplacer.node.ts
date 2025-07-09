import {
	IExecuteFunctions,
	INodeExecutionData,
	INodeType,
	INodeTypeDescription,
	NodeConnectionType,
	NodeOperationError,
} from 'n8n-workflow';

export class TextReplacer implements INodeType {
	description: INodeTypeDescription = {
		displayName: 'Text Replacer',
		name: 'textReplacer',
		icon: 'file:textReplace.svg',
		group: ['transform'],
		version: 1,
		subtitle: 'Reemplaza múltiples placeholders en texto',
		description: 'Reemplaza placeholders definidos por el usuario en un texto de entrada con valores dinámicos',
		defaults: {
			name: 'Text Replacer',
			color: '#772244',
		},
		inputs: [NodeConnectionType.Main],
		outputs: [NodeConnectionType.Main],
		properties: [
			{
				displayName: 'Input Text',
				name: 'inputText',
				type: 'string',
				required: true,
				default: '',
				description: 'Texto que contiene los placeholders a reemplazar',
				typeOptions: {
					rows: 4,
				},
			},
			{
				displayName: 'Output Key Name',
				name: 'outputKey',
				type: 'string',
				required: true,
				default: 'processedText',
				description: 'Nombre de la key en el JSON de salida que contendrá el texto procesado',
			},
			{
				displayName: 'Replacements',
				name: 'replacements',
				type: 'collection',
				default: {},
				description: 'Grupos de placeholder/replacer para procesar',
				typeOptions: {
					multipleValues: true,
				},
				options: [
					{
						displayName: 'Placeholder',
						name: 'placeholder',
						type: 'string',
						default: '$$placeholder$$',
						description: 'El texto a buscar en el input (ej: $$nombre$$)',
					},
					{
						displayName: 'Replacer',
						name: 'replacer',
						type: 'string',
						default: '',
						description: 'El valor que reemplazará al placeholder',
					},
				],
			},
		],
	};

	async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
		const items = this.getInputData();
		const returnData: INodeExecutionData[] = [];

		for (let i = 0; i < items.length; i++) {
			try {
				const inputText = this.getNodeParameter('inputText', i) as string;
				let outputKey = this.getNodeParameter('outputKey', i) as string;
				const replacements = this.getNodeParameter('replacements', i) as Array<{
					placeholder: string;
					replacer: string;
				}>;

				console.log(`[TextReplacer] Procesando item ${i + 1}/${items.length}`);

				// Validar parámetros básicos
				if (!inputText) {
					console.log(`[TextReplacer] Warning: No input text for item ${i + 1}`);
					returnData.push({
						json: items[i].json,
					});
					continue;
				}

				if (!outputKey || !outputKey.trim()) {
					outputKey = 'processedText';
				}

				if (!replacements || replacements.length === 0) {
					console.log(`[TextReplacer] Warning: No replacements for item ${i + 1}`);
					returnData.push({
						json: {
							...items[i].json,
							[outputKey]: inputText,
						},
					});
					continue;
				}

				let processedText = inputText;

				// Procesar reemplazos
				for (const replacement of replacements) {
					const { placeholder, replacer } = replacement;

					if (!placeholder || !placeholder.trim()) {
						continue;
					}

					if (!processedText.includes(placeholder)) {
						console.log(`[TextReplacer] Warning: Placeholder "${placeholder}" not found`);
						continue;
					}

					const placeholderRegex = new RegExp(
						placeholder.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'),
						'g'
					);
					
					processedText = processedText.replace(placeholderRegex, replacer || '');
					console.log(`[TextReplacer] Replaced "${placeholder}" with "${replacer}"`);
				}

				const result: INodeExecutionData = {
					json: {
						...items[i].json,
						[outputKey]: processedText,
					},
				};

				returnData.push(result);

			} catch (error) {
				console.log(`[TextReplacer] Error:`, error);
				if (this.continueOnFail()) {
					returnData.push({
						json: {
							...items[i].json,
							error: (error as Error).message,
						},
					});
					continue;
				}
				throw new NodeOperationError(this.getNode(), error as Error, {
					itemIndex: i,
				});
			}
		}

		console.log(`[TextReplacer] Execution completed. Processed ${returnData.length} items.`);
		return [returnData];
	}
} 